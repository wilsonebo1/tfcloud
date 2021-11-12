# Segmented modeling

Segmented modeling allows customers to split their datasets into multiple segments and model each segment as a separate project.
The feature is released for public preview in 7.2 and GA in 7.3.

## Configuration

Segmented modeling does not require any special services to be installed. 

## Cluster size

Running a segmented project implies multiplying project running cost by the number of segments. Therefore,
the following cluster sizes are recommended:

| Size |  Webserver | EDA workers | Modeling workers
|------|:----------:|:-----------:|:---------------:|
| Up to 1GB of data or up to 10 segments | 2xlarge |  2 | 5-10
| Up to 5 GB of data or up to 100 segments | 2xlarge |  5 | 20-40
| Up to 100 GB of data | 4xlarge | 10 | 40-80

Note that this the number of workers a recommendation, not a requirements: customers can run
 segmented modeling with less workers, but it will take more time.   

## Usage

For 7.2 version users also need to have the feature flag enabled in order to be able to configure segmented projects 
- "Enable Project Segmentation for Time Series Projects" (`ENABLE_TIME_SERIES_PROJECT_SEGMENTATION`);