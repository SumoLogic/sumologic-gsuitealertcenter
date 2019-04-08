#!/usr/bin/env bash

# pip install twine wheel setuptools

rm -r build/ dist/ sumologic_gsuitealertcenter.egg-info/
rm -r sumogsuitealertscollector/__pycache__/  sumogsuitealertscollector/sumoclient/__pycache__/ sumogsuitealertscollector/common/__pycache__/ sumogsuitealertscollector/omnistorage/__pycache__/
rm sumogsuitealertscollector/*.pyc sumogsuitealertscollector/sumoclient/*.pyc sumogsuitealertscollector/common/*.pyc sumogsuitealertscollector/omnistorage/*.pyc
rm sumogsuitealertscollector/omnistorage/*.db
rm sumogsuitealertscollector.zip

python setup.py sdist bdist_wheel
#python -m twine upload dist/*


