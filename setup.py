from setuptools import setup, find_packages
from os.path import join, dirname, abspath
import io

here = abspath(dirname(__file__))

with open(join(here, 'VERSION')) as VERSION_FILE:
    __versionstr__ = VERSION_FILE.read().strip()


with open(join(here, 'requirements.txt')) as REQUIREMENTS:
    INSTALL_REQUIRES = REQUIREMENTS.read().split('\n')


with io.open(join(here, 'README.md'), encoding='utf-8') as f:
    long_description = f.read()


CONSOLE_SCRIPTS = [
    'sumogsuitealertscollector=sumogsuitealertscollector.main:main'
]

INSTALL_REQUIRES.extend([
    'futures;python_version<"3.2"',
    'future-fstrings;python_version<"3.6"'
])

setup(
    name="sumologic-gsuitealertcenter",
    version=__versionstr__,
    packages=find_packages(),
    install_requires=INSTALL_REQUIRES,
    # PyPI metadata
    author="SumoLogic",
    author_email="it@sumologic.com, apps-team@sumologic.com",
    description="Sumo Logic collection solution for G Suite Alert Center",
    license="PSF",
    long_description=long_description,
    long_description_content_type='text/markdown',
    keywords="sumologic python rest api log management analytics logreduce g suite agent security siem collector forwarder",
    url="https://github.com/SumoLogic/sumologic-gsuitealertcenter",
    zip_safe=True,
    include_package_data=True,
    classifiers=[
        'Development Status :: 4 - Beta',
        'Intended Audience :: Developers',
        'Programming Language :: Python :: 2.7',
        'Programming Language :: Python :: 3.7',
        'Operating System :: OS Independent'
    ],
    entry_points={
        'console_scripts': CONSOLE_SCRIPTS,
    }

)
