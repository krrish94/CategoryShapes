# Download data for project
wget http://cs.berkeley.edu/~akar/categoryShapes/data.tar.gz
# Extract the contents of the archive
tar -xvzf data.tar.gz
# Move the tar.gz file into the data folder (formed upon extraction of the archive contents)
mv data.tar.gz data/

# Download PASCAL VOC
wget http://host.robots.ox.ac.uk:8080/pascal/VOC/voc2012/VOCtrainval_11-May-2012.tar
# Extract the contents of the archive
tar -xf VOCtrainval_11-May-2012.tar
# Move the extracted folder to the data directory
mv VOCdevkit data/
# Move the tar file into the data folder
mv VOCtrainval_11-May-2012.tar data/

# Download PASCAL 3D
wget ftp://cs.stanford.edu/cs/cvgl/PASCAL3D+_release1.0.zip
# Extract the contents from the zip file
unzip PASCAL3D+_release1.0.zip
# Move the zip file, and the extracted folder to the data directory
mv PASCAL3D+* data/

# Download and extract vlfeat in the external directory
cd external/
wget http://www.vlfeat.org/download/vlfeat-0.9.20-bin.tar.gz
tar -xvzf vlfeat-0.9.20-bin.tar.gz
