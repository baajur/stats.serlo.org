package main

import (
	"fmt"
	"io/ioutil"

	"github.com/go-yaml/yaml"
)

type schedulerConfig struct {
	IntervalInMin  int `yaml:"IntervalInMin"`
	DelayTimeInSec int `yaml:"DelayTimeInSec"`
}

type loggingConfig struct {
	Level string `yaml:"Level"`
	File  string `yaml:"File"`
	Truncate bool `yaml:"Truncate"`
}

type importerConfig struct {
	Logging         loggingConfig   `yaml:"Logging"`
	Scheduler       schedulerConfig `yaml:"Scheduler"`
}

func readImporterConfig() (*importerConfig, error) {
	config := &importerConfig{}
	configBytes, err := ioutil.ReadFile(importerConfigPath)
	if err != nil {
		return nil, fmt.Errorf("config error: read config=%s error=%s", importerConfigPath, err.Error())
	}
	err = yaml.Unmarshal(configBytes, &config)
	if err != nil {
		return nil, fmt.Errorf("config error: unmarshal error in puppet config=%s error=%s",
			importerConfigPath,
			err.Error())
	}

	err = validateImporterConfig(config)
	return config, err
}

func validateImporterConfig(config *importerConfig) error {
	if config.Scheduler.IntervalInMin < 10 {
		return fmt.Errorf("Scheduler.IntervalInMin not set or lower then 10 minutes")
	}
	return nil
}