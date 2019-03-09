#!/usr/bin/env bash

# pip install twine wheel setuptools

rm -r build/ dist/ sumologic_gsuitealertcenter.egg-info/ sumogsuitealertscollector/__pycache__
rm sumogsuitealertscollector/*.pyc
python setup.py sdist bdist_wheel
python -m twine upload dist/*
