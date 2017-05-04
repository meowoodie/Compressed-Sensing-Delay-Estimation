Delay Estimation with Compressed Sensing
===

### Test Results on Utah Dataset

We test our algorithm on [Utah dataset](http://home.chpc.utah.edu/~u0992976/Socal/). It contains 3 stations with good quality data, 3 stations with bad quality data, and a center station `001`. We compared the results of compressed sensing method with conventional cross-correlation method between center station and good/bad stations. 

At first, we stacked data in one month (week) into 5 mins window.
- Stack data in one month (week) into only one day, and average the stacked data bit by bit. 
- Stack averaged one day data into a 5 minutes window.

You can reach the result by visiting [Utah result]()

