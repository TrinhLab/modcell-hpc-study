This is a companion repository to [modcell-hpc](https://github.com/TrinhLab/modcell-hpc) used to store results and analysis.


The Matlab cobratoolbox is used in some steps for analyzing problems, the version used in all cases corresponds to the commit hash f3fe20df5c977cf0d212e12b1763bd96d15c8760. Where python cobtratoolbox is used requirements.txt will be provided. In general, all python analysis was performed inside a virtual environment, see `~/.requirements.txt`


# Bonus
Procedures explained in detail elsewhere but placed it here for convenience.

## Environment variables
The code depends on these so make sure to set this up according to the instructions on [modcell-hpc](https://github.com/TrinhLab/modcell-hpc) under the section ``Running modcell-hpc''.

## Setting up virtual envirnoment
~~~
virtualenv  ~/.envs/modcell-analysis
source ~/.envs/modcell-analysis/bin/activate
pip install -r $MODCELLHPC_S_PATH/requirements.txt
~~~

To run the environment in jupyter notebooks you must install the kernel. From within the
environment run:

~~~
pip install ipykernel
ipython kernel install --user --name=modcell-analysis
~~~
If the avove leads to some issues you also run:
~~~
python -m ipykernel install --user --name=modcell-analysis
~~~

