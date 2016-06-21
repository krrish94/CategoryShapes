% Compiles external libraries required to run this code

cd 'nrsfm';
mex computeH.c
cd ..

cd external/SIRFS
compile

cd ../..
