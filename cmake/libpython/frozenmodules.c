/* Dummy frozen modules initializer for building _freeze_importlib
   under MS Windows, as using the frozen.c from the Python
   distribution results in a circular include of importlib.h
*/
#include <Python.h>
#include <marshal.h>

const struct _frozen *PyImport_FrozenModules;
