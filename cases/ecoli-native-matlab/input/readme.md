# Model config
Model parameters are adapted from  Kamp2017 in iJO1366 to iML1515:
- glucose uptake limit: 15.
- ATP maintenance: Default iML1515 value.
- min growth rate:
	- The minimum biomass yield is set to 0.01 gDW mmol-1 glc. in iJO1366
	- iJO1366 with 3.15 ATPM, 15 glc uptake, and 0 o2 uptake has a growth rate of 0.3797 and thus a max yield of 0.0253. Thus they used 0.01/0.0253 = 39.53% ~= 40% of the maximum growth rate.
	- The max growth rate of iML1515 under the conditions stated so far is 0.2661 so we could use 0.2661*0.4 = 0.1064. but 40% is unnecesarly high and can exclude good designs, 20% of the max. wild-type growth rate is still a conservative value: 0.2661*0.2 = 0.0532

# Products
- `quin` was removed from pathway_table.csv since iML1515 cannot secrete this metabolite.
