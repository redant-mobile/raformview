RAFormViewKit
=============

Purpose
-------

RAFormKit is a simple editable form with some key features:

* Form validation (using regular expressions)
* Configurable from a plist
* Pre-fillable fields
* Keyboard scrolling
* Lightweight
* ARC-ready

![Screen shot](https://dl.dropbox.com/u/64353587/github/raformview/screenshot.png "Example")

Usage
-----

    RAFormViewController *vc = [[RAFormViewController alloc] initWithPlistNamed:@"MyForm"];

Or

    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"Mr", @"title", @"UK", @"country", nil];
    RAFormViewController *vc = [[RAFormViewController alloc] initWithPlistNamed:@"MyForm" prefilledValues:dict];

And then

    // Set delegate (assume self implements <RAFormViewControllerDelegate>)
    vc.delegate = self;

    // Display
    [self.navigationController pushViewController:vc animated:YES];


Configuration
-------------

All form configuration is done in a plist. For each row, these keys are mandatory:

* title (the name of the field)
* cellIdentifier (RAFormTextEntryCell, RAFormTextSelectionCell, RAFormSwitchCell, RAFormSecureTextEntryCell)

And these keys are optional:

* required (set `YES` if the field must contain something)
* validation (regular expression to validate field)
* error (a string to show as the error when validation fails)
* property (the name of the key in the pre-filling dictionary)
* autoCapitalizeType (A value from `UITextAutocapitalizationType`)
* autoCorrectStyle (A value from `UITextAutocorrectionType`)
* keyboardType (A value from `UIKeyboardType`)


Delegate Methods and Initializers
---------------------------------

There is one delegate method defined in the `RAFormViewControllerDelegate` protocol:

    - (void)submitWithArray:(NSArray *)array;

There are a choice of 2 initalizers:

    - (id)initWithPlistNamed:(NSString *)plist;
    
    - (id)initWithPlistNamed:(NSString *)plist prefilledValues:(NSDictionary *)values;



What's Included
---------------

### RAFormViewKit

Drag this into your project

### RAFormViewSampleApp

The code (and project file) for the sample app.


Known Issues
------------

*Hardware keyboards are not correctly handled.


About Us
--------

RAFormView was written by the developers at Red Ant. [http://redant.com]


