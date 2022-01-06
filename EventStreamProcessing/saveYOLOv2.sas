*- Example to save a YOLOv2 ONNX model to ASTORE and download locally for use in Event Stream Processing -*;

*- Load and re-size images -*;
proc cas;
   addcaslib/activeonadd=False
      dataSource="PATH"
      name='data'
      path='/path/to/data'
      subdirectories=True;
   run;

   loadactionset "image";
   image.loadImages / caslib='data'
      path="yoloimage"
      decode=TRUE
      addColumns={"CHANNELCOUNT", "CHANNELTYPE", "HEIGHT", "WIDTH"}
      casout={name="image_loaded", replication=0, replace=true};
   run;

   image.processimages/
      table='image_loaded',
      imagefunctions={
         {functionoptions={functiontype='resize', w=416, h=416}}
      },
      decode=FALSE,
      casout={name='image_resized',replace=True},
      copyvars={"_HEIGHT_","_WIDTH_"}
;

run;

*- Set COCO dataset labels that were used in model training -*;
%let labels = %str("person" "bicycle" "car" "motorbike" "aeroplane" "bus" "train" "truck" "boat" "traffic light"
"fire hydrant" "stop sign" "parking meter" "bench" "bird" "cat" "dog" "horse" "sheep" "cow"
"elephant" "bear" "zebra" "giraffe" "backpack" "umbrella" "handbag" "tie" "suitcase" "frisbee"
"skis" "snowboard" "sports ball" "kite" "baseball bat" "baseball glove" "skateboard" "surfboard" "tennis racket" "bottle"
"wine glass" "cup" "fork" "knife" "spoon" "bowl" "banana" "apple" "sandwich" "orange"
"broccoli" "carrot" "hot dog" "pizza" "donut" "cake" "chair" "sofa" "pottedplant" "bed"
"diningtable" "toilet" "tvmonitor" "laptop" "mouse" "remote" "keyboard" "cell phone" "microwave" "oven"
"toaster" "sink" "refrigerator" "book" "clock" "vase" "scissors" "teddy bear" "hair drier" "toothbrush");

*- Set onnxfile path -*;
%let onnxfile=%str("yolov2-coco-9.onnx");

*- Describe ONNX directly (without saving to ASTORE first) -*;
proc astore;
describe onnx=&onnxfile;
run;

*- Save ONNX to RSTORE -*;
proc astore;
saveas onnx=&onnxfile rstore=sascas1.yolov2store data=sascas1.image_resized
       inputs=(var=_image_ varbinaryType=UINT8 inputShapeOrder=NHWC inputColorOrder=RGB preprocess=NORMALIZE normFactor=255 modelShapeOrder=NCHW modelColorOrder=RGB shape=(1 3 416 416) )
       modelType=YOLOV2
       maxObjects=6
       labels=(&labels)
       numAnchors=5
       anchorBoxes=(1.3221 1.73145 3.19275 4.00944 5.05587 8.09892 9.47112 4.84053 11.2364 10.0071)
       ;
run;

*- Download RSTORE locally to be used for Event Stream Processing -*;
proc astore;
        download rstore=sascas1.yolov2store store="yolov2store.sasast";
run;
