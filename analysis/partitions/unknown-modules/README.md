Here we would like to ask the question of how a chassis behaves towards modules that were not part of the original design.

# Procedure
- Split products randomly into two subsets and simulate
- Apply designs to model and recalculate objectives for all original modules
- Compare the average compatibility of the same module group between the case where modules were not part of the original design and the case in which they were
- Compare the best performing (most compatible) designs with the best performing designs in the case were all modules were simultaneosly considered.
- Are there any patterns regarding what unkown products tend to couple better by default? At least I could rank the unkown modules with the best compatibility and/or the designs with the best compatiblity towards unkown products.

One caveat of the analysis is that the random split might be very influencial in the outcome, so I might want to do it for at least two different random splits. Or perhaps more than that, and then do the analysis as an "average".
For example:
- Do 3 random splits
- Report unknown module compatibility distribution for each case independently
- Then for each case compute most compatible unkown modules, and designs with best compatibility towards unkown modules. Again present these, and expect similar behavior? If not, at least we can see that the choice of products is highly influential (which raises the quewstion of how to pick products to design a platform to maximize unkown compatibility)

