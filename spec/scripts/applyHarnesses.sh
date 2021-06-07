# SafeTransfer simplification
perl -0777 -i -pe 's/safeT/t/g' contracts/Controller.sol

# Virtualize functions
perl -0777 -i -pe 's/external\s*override\s*nonReentrant/external virtual override nonReentrant/g' contracts/Controller.sol
perl -0777 -i -pe 's/internal\s*view\s*returns/internal view virtual returns/g' contracts/options/QToken.sol
perl -0777 -i -pe 's/internal\s*pure\s*returns/internal pure virtual returns/g' contracts/options/QToken.sol

perl -0777 -i -pe 's/internal view returns/internal view virtual returns/g' contracts/utils/EIP712MetaTransaction.sol