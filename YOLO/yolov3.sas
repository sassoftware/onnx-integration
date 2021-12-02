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
      steps={
         {step={
            stepType='resize',
            type='LETTERBOX',
            width= 416,
            height= 416,
            paddingmethod= 'CONSTANT',
            b= 128,
            g= 128,
            r= 128
         }}
      },
      decode=FALSE,
      casout={name='image_resized',replace=True},
      copyvars={"_HEIGHT_","_WIDTH_"};
run;


%let labels = %str("person" "bicycle" "car" "motorbike" "aeroplane" "bus" "train" "truck" "boat" "traffic light"
"fire hydrant" "stop sign" "parking meter" "bench" "bird" "cat" "dog" "horse" "sheep" "cow"
"elephant" "bear" "zebra" "giraffe" "backpack" "umbrella" "handbag" "tie" "suitcase" "frisbee"
"skis" "snowboard" "sports ball" "kite" "baseball bat" "baseball glove" "skateboard" "surfboard" "tennis racket" "bottle"
"wine glass" "cup" "fork" "knife" "spoon" "bowl" "banana" "apple" "sandwich" "orange"
"broccoli" "carrot" "hot dog" "pizza" "donut" "cake" "chair" "sofa" "pottedplant" "bed"
"diningtable" "toilet" "tvmonitor" "laptop" "mouse" "remote" "keyboard" "cell phone" "microwave" "oven"
"toaster" "sink" "refrigerator" "book" "clock" "vase" "scissors" "teddy bear" "hair drier" "toothbrush");

%let onnxfile=%str("tiny-yolov3-11.onnx");

proc astore;
describe onnx=&onnxfile;
run;

proc astore;
saveas onnx=&onnxfile rstore=sascas1.yolov3store data=sascas1.image_resized
       inputs=(var=_image_ varbinaryType=UINT8 inputShapeOrder=NHWC inputColorOrder=BGR preprocess=NORMALIZE normFactor=255 modelShapeOrder=NCHW modelColorOrder=RGB shape=(1 3 416 416) )
       inputs=(vars=(_height_ _width_ ) shape=(1 2))
       modelType=YOLOV3
       maxObjects=6
       labels=(&labels)

       ;
run;

proc astore;
score rstore=sascas1.yolov3store data=sascas1.image_resized out=sascas1.out copyvars=(_id_ _path_); 
run;

proc print data=sascas1.out; run;

