# -*- coding: future_fstrings -*-
import os
from sumoclient.utils import get_logger
import yaml

log = get_logger(__name__)


class Config(object):

    def get_config(self, config_filename, root_dir, input_cfgpath=''):
        ''' reads base config and merges with user config'''
        base_config_path = os.path.join(root_dir, config_filename)
        base_config = self.read_config(base_config_path)
        home_dir = os.path.join(os.path.expanduser("~"), config_filename)
        cfg_locations = [input_cfgpath, home_dir, os.getenv("SUMO_API_COLLECTOR_CONF", '')]
        configpath = self.get_config_path(cfg_locations)
        usercfg = self.read_config(configpath)
        self.config = self.merge_config(base_config, usercfg)
        log.info(f"config object created")
        return self.config

    def merge_config(self, base_config, usercfg):
        for k, v in usercfg.items():
            if k in base_config:
                base_config[k].update(v)
            else:
                base_config[k] = v
        return base_config

    def get_config_path(self, cfg_locations):
        for filepath in cfg_locations:
            if os.path.isfile(filepath):
                return filepath

        raise Exception(f"No Config file Found in following locations {cfg_locations}")

    @classmethod
    def read_config(cls, filepath):
        log.info(f"Reading config file: {filepath}")
        config = None
        with open(filepath, 'r') as stream:
            try:
                config = yaml.load(stream)
            except yaml.YAMLError as exc:
                log.error(f"Unable to read config {filepath} Error: {exc}")
        return config
