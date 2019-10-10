#!/usr/bin/env python3

"""
Create a modcell input file for all metabolites with exchange reactions with exclusions (e.g. omit substrate)
"""

import cobra as cb
import pandas as pd
import csv
import re

# Corrections
#corrections = { 'mththf_c': 'DM_mththf_c'}

model = cb.io.load_json_model('../../ecoli-native-matlab/input/parent-model-generation/iML1515.json')
targets = pd.read_csv('../../ecoli-native-matlab/input/parse-targets/aerobic_cands.csv')

def add_ex_rxn(met_id):

    # Check if demand reaction already present
    try:
        reaction = model.reactions.get_by_id(f"DM_{met_id}")
        return reaction
    except Exception as error:
        pass

    reaction = cb.Reaction (f"EX_{met_id}", name=f"Artificial exchange {met_id}", lower_bound = 0, upper_bound = 1000)
    reaction.add_metabolites({model.metabolites.get_by_id(met_id):-1})
    model.add_reactions([reaction])
    return reaction

produce = []
for met_id in targets['Metabolite ID']:
    met_id = met_id.replace('-','__') # Fix nomenclature issue
    # Check metabolit is in the model
    try:
        model.metabolites.get_by_id(met_id)
    except Exception as error:
        print(f"Metabolite likely not in the model: {met_id}")
        continue

    try:
        #rxn = model.add_boundary(model.metabolites.get_by_id(met_id))
        rxn = add_ex_rxn(met_id)
        produce.append(rxn.id)
    except Exception as error:
        if not met_id.endswith('_e'):
            raise error
        produce.append('EX_{}'.format(met_id))

# Pathway table
headers = ['id','name','rxns','product_id','product_tags','precursor_ids','litref','notes']
def get_met(model, ex_rxn_id):
       rxn = model.reactions.get_by_id(ex_rxn_id)
       mets = [k for k,v in rxn.metabolites.items()]
       if len(mets) == 1:
           met = mets[0]
       else:
           raise ValueError('An exchange reaction involved multiple metabolites')
       return met

with open ('pathway_table.csv', 'w') as f:
    writer = csv.DictWriter(f, fieldnames=headers)
    writer.writeheader()
    for rxn_id in produce:
        row = {k:None for k in headers}
        met_id_no_comp = re.search('(EX|DM)_(.*)_.*', rxn_id).group(2)
        row['id'] = met_id_no_comp
        row['name'] = get_met(model, rxn_id).name
        row['rxns'] = [rxn_id]
        row['product_id'] = met_id_no_comp
        writer.writerow(row)

# Reaction table
headers = ['id', 'name', 'rxn_str', 'kegg_id', 'bigg_id', 'ec_number','notes']
with open ('reaction_table.csv', 'w') as f:
    writer = csv.DictWriter(f, fieldnames=headers)
    writer.writeheader()
    for rxn_id in produce:
        row = {k:None for k in headers}
        row['id'] = rxn_id
        rxn = model.reactions.get_by_id(rxn_id)
        row['name'] = rxn.name
        row['rxn_str'] = re.sub('-->', '=>', rxn.reaction) # Arrows need to be => and <=>
        writer.writerow(row)

# Metabolite table
headers = ['id','name','formula','charge','kegg_id','bigg_id','notes']
with open ('metabolite_table.csv', 'w') as f:
    writer = csv.DictWriter(f, fieldnames=headers)
    writer.writeheader()
    for rxn_id in produce:
        row = {k:None for k in headers}
        met = get_met(model, rxn_id)
        row['id'] = met.id[:-2] # get rid of compartment
        row['name'] = met.name
        row['formula'] =  met.formula
        row['charge'] =  met.charge
        writer.writerow(row)
