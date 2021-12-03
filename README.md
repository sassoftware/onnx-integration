# SAS Analytic Store (ASTORE) Integration with ONNX

## Overview

Examples showing various applications for SAS ASTORE actions that work with ONNX files. 

### What's New

Several new ASTORE actions are used in these examples including:  
- aStore.check  
- aStore.describe support ONNX file types  
- aStore.saveas  
- aStore.extract 
 

### Prerequisites

Python Requirements:
- Python 3.+  
- Install the following Python modules:  
    - [swat](https://sassoftware.github.io/python-swat/install.html) 
    - [numpy](https://numpy.org/install/) (optional)
    - [PIL](https://pillow.readthedocs.io/en/stable/installation.html) (optional)
    - [matplotlib](https://matplotlib.org/stable/users/getting_started/index.html#installation-quick-start) (optional)
- Jupyter Notebook (for running the examples)
 

SAS Requirements:
- [SAS Visual Data Mining and Machine Learning](https://support.sas.com/en/software/visual-data-mining-and-machine-learning-support.html#documentation)
- [SAS Studio](https://support.sas.com/en/software/studio-support.html#documentation)
- [SAS Event Stream Processing Studio](https://support.sas.com/en/software/event-stream-processing-support.html#documentation) (if following the ESP example)
- a running CAS server
 


Other:
- a valid ONNX file

## Getting Started

The following code snippets will take you through how to use the new ASTORE actions. You will need a valid ONNX file. 

### Read ONNX
```
onnxfile = /path/to/onnxmodel.onnx
with open(onnxfile,"rb") as file:
    blob = file.read()
blob_ = swat.blob(blob)

```
### Check if ONNX model is valid
```
s.aStore.check(onnx=blob_)
```

### Describe ONNX model
```
s.aStore.describe(onnx=blob_)
```

### Save ONNX model to ASTORE
The saveas action parameters are specific to the ONNX model being used. The following code snippet shows saving a VGG model to ASTORE - example can be found in the ImageClassification folder. 
```
...
# load and re-shape images
...
# Create output class index list (1000 classes)
boxidx = [str(i) for i in range(1000)] 

s.aStore.saveas(
    table="imagesResized",
    rstore=dict(name="onnxstore",replace=True),
    onnx=blob_,
    inputs=[dict(vars=["_image_"],shape=[1,3,224,224],varbinrayType="UINT8",
        inputShapeOrder="NHWC", inputColorOrder="BGR",
        modelShapeOrder="NCHW", modelColorOrder="RGB",
        preprocess="NORMALIZE", normFactor=255,
        normmean=normmean_vals,
        normstd=normstd_vals)],
    outputs=[dict(name="output",shape=[1,1000], labels=boxidx, labeldim=[1], postprocess="SOFTMAX")]
)
```
### Score data with saved ASTORE
Scoring data with an ASTORE generated from an ONNX model is exactly the same as scoring with a regular ASTORE.
```
s.aStore.score(rstore="onnxstore", table="imagesResized",
                out=dict(name="outscore",replace=True),
                copyvars=("_path_")
                )
```

### Extract ONNX model from previously saved ASTORE
The extract action pulls the ONNX model from the generated ASTORE which allows users to investigate the ONNX model contents the ASTORE was created from. This action only works with ASTOREs that were saved from an ONNX model originally.
```
s.aStore.extract(rstore="onnxstore")
```

### Troubleshooting


## Contributing

> We are not accepting contributions at this time.


## License

> This project is licensed under the [Apache 2.0 License](LICENSE).

## Additional Resources

* [ASTORE Documentation](https://go.documentation.sas.com/doc/en/pgmsascdc/v_018/casactml/casactml_astore_toc.htm)  
* [SAS Communities: ASTORE Wrapper for ONNX, Dataviz in Microsoft 365](https://communities.sas.com/t5/SAS-Community-Events/ASTORE-Wrapper-for-ONNX-Dataviz-in-Microsoft-365-SAS-Viya-2021-1/ev-p/780472)  
* Blog posts (coming soon)
* Technical details about [how SAS Event Stream Processing deploys offline model](https://go.documentation.sas.com/?cdcId=espcdc&cdcVersion=6.2&docsetId=espan&docsetTarget=p0wmfh8n175cvmn14z6iamhb8zfk.htm&locale=en)
* Reference for [Using Python Interface](https://go.documentation.sas.com/?cdcId=espcdc&cdcVersion=6.2&docsetId=espmdlpython&docsetTarget=titlepage.htm&locale=en)
* Reference for [Getting Started with SAS Viya for Python](https://go.documentation.sas.com/?cdcId=pgmsascdc&cdcVersion=9.4_3.5&docsetId=caspg3&docsetTarget=titlepage.htm&locale=en)
* An [overview](https://support.sas.com/en/software/visual-analytics-support.html#documentation) of SAS Visual Analytics
* SAS Support Communities [website](https://communities.sas.com/)
* SAS [Event Stream Processing Free Trial](https://www.sas.com/en_us/software/event-stream-processing.html)
