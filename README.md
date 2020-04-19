# step2gltf
Example program of how to convert ISO 10303 STEP files (AP203 and AP 214) to GLTF 2.0 using OpenCascade.

## Dependencies

You need OpenCascade 7.4.1.dev with RapidJSON.

## Compiling

### Prepare on Astra Linux

```
sudo apt-get install ca-certificates \
    libcurl3 libuv1 cmake \
    libfreetype6-dev \
    tcl-dev tk-dev \
    libxmu-dev libxi-dev
```

### Compiling RapidJSON from source:

To compile from source (on OSX make sure to use gcc, not clang):

```
git clone https://github.com/Tencent/rapidjson.git
cd rapidjson
git checkout 8f4c021fa2f1e001d2376095928fc0532adf2ae6
mkdir build
cd build
cmake ..
sudo make install
```


### Compiling OpenCascade from source:

Required latest OpenCascade sources, otherwise there will be
no RWGltf_CafWriter class.

To compile from source (on OSX make sure to use gcc, not clang):

```
git clone https://git.dev.opencascade.org/repos/occt.git
cd occt
git checkout 1e1b83c07b17144447e9e8b104ad0682655310db
mkdir build
cd build
cmake .. -DUSE_RAPIDJSON:BOOL=ON
sudo make install
```

### Compiling step2gltf

To compile from source on OSX:
```
make
```

## Running

Once you have compiled it,
just use it as:

```
step2gltf STEPFILENAME GLTFFILENAME
```

File extension defines glTF 2.0 variant:
 - ".gltf" - glTF with base64 binary resourses embedded in JSON.
 - ".glb"  - binary glTF.

You may also need to specify LD_LIBRARY_PATH to run on Astra Linux
```
LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH step2gltf STEPFILENAME GLTFFILENAME
```

## Validating

https://github.khronos.org/glTF-Validator/

Binary glTF shall have \*.glb extension.

## Rendering gLTF

Open https://gltf-viewer.donmccurdy.com and upload result file.

## GLTF 2.0 Specification

https://github.com/KhronosGroup/glTF/blob/master/README.md

# Implementation Details

## Meshing algorithm

The algorithm of shape triangulation is provided by the functionality of BRepMesh_IncrementalMesh class, which adds a triangulation of the shape to its topological data structure. This triangulation is used to visualize the shape in shaded mode.

![Deflection parameters of BRepMesh_IncrementalMesh algorithm](https://www.opencascade.com/doc/occt-7.1.0/overview/html/modeling_algos_image056.png)

Linear deflection limits the distance between triangles and the face interior.

![Linear deflection](https://www.opencascade.com/doc/occt-7.1.0/overview/html/modeling_algos_image057.png)

Note that if a given value of linear deflection is less than shape tolerance then the algorithm will skip this value and will take into account the shape tolerance.

The application should provide deflection parameters to compute a satisfactory mesh. Angular deflection is relatively simple and allows using a default value (12-20 degrees). Linear deflection has an absolute meaning and the application should provide the correct value for its models. Giving small values may result in a too huge mesh (consuming a lot of memory, which results in a long computation time and slow rendering) while big values result in an ugly mesh.

For an application working in dimensions known in advance it can be reasonable to use the absolute linear deflection for all models. This provides meshes according to metrics and precision used in the application (for example, it it is known that the model will be stored in meters, 0.004 m is enough for most tasks).

Source: https://www.opencascade.com/doc/occt-7.1.0/overview/html/occt_user_guides__modeling_algos.html#occt_modalg_11_2
