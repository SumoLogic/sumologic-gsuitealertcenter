#!/usr/bin/env bash

# pip install twine wheel setuptools

rm -r build/ dist/ sumologic_gsuitealertcenter.egg-info/ sumogsuitealertscollector/__pycache__
rm sumogsuitealertscollector/*.pyc
python setup.py sdist bdist_wheel
# python -m twine upload dist/*
    python -m twine upload -u himanshu_pal -p himanshu@219 dist/*  --repository-url https://test.pypi.org/legacy/
# python -m twine upload -u himanshu_pal -p himanshu@219 --repository-url https://pypi.org/legacy/ dist/*
# pip install --extra-index-url https://testpypi.python.org/pypi sumologic-gsuitealertcenter