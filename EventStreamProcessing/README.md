Both YOLOv2 and YOLOv3 models can be saved to an analytic store, and then score new data with the analytic store directly in SAS Event Stream Processing (ESP). Before deploying the saved ONNX analytic store to ESP, we need to download the store from CAS to a loal file with the ASTORE `download` statement. Complete code for saving a YOLOv2 ONNX to analytic store and saving to local file can be found in **saveYOLOv2.sas**.
  
The XML file for this YOLOv2 model can found in **model.xml**. An important snippet from the XML file is shown below:  
  
```
        <window-model-reader name="w_reader" model-type="astore">
          <parameters>
            <properties>
              <property name="reference"><![CDATA[yolov2store.sasast]]></property>
            </properties>
          </parameters>
        </window-model-reader>
```

The XML file shows there is a source window, which takes an image as input.  
The source window is connected to a calculate window, which does the image resizing.  
A score window takes the analytic store (the one downloaded from CAS) from the model loader window, an input image from the calculate window, and then produces the output -- bounding box coordinates of the detected objects.
