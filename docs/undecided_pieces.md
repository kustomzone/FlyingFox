I am not very confident in the decisions on this todo list, that is why they are here instead of on github issues. 

maybe make random number generator better with game to stop people from revealing:
When you commit to a bet, you at the same time open up the opportunity for anyone to make a bet against you at a 2:1 ratio (eg. someone can claim "I think you'll be heads", and if it's heads they get 1 and if it's tails they lose 2, and similarly someone can claim "I think you'll be tails", and if it's tails they get 1 and if it's heads they lose 2). So if you reveal the bit to anyone else, even via a funky scheme like ZKP, they can anonymously take expected profit from you.

Make random number generator to decentivize collusion:
People who choose the minority bit have to pay less fee.

Instead of storing signatures in each block, only store a max of one signature per validator address. A signature over a recent block is also a signature over the entire chain, because the block contains a hash of the previous block.

Maybe the blockmaker should be rewarded for each signer he includes. This would disincentivize him from trying to cheat by including less signers.
so say minsigners = 10, maxsigners = 15

say there are 10 signers
reward is 0

11 signers
reward is 20%

12 signers
reward is 40%

minimum amount of money per address. maybe a new tx type for deleting addresses would be useful? We could pay people for deleting addresses.

maybe we should charge proof of work for creating blocks, and have it increase exponentially depending how many blocks are being skipped?
