YOLO-bot
==========

Perhaps the second dumbest idea I've ever had.

Promo
- Smart camera application. Add smart "vision" to your camera, connect what you "see" to Apple Shortcuts.

Description
- YOLObot uses advanced artificial intelligence (AI) to recognize the world around you and take action. YOLObot is a smart camera app that allows you to recognize everyday objects and quickly take common actions like dialing a phone number, looking up products barcodes, getting directions to an address, or even launching a fitness app to record what you're eating. 

- The secret is YOLObot's ability to leverage CoreML to recognize over 500 objects, and linking the "smart camera" to Apple Shortcuts.

Keywords
- smart,camera,yolo,OCR,object,action,short,cut

v1.1
---
- ☑️ Add www feature
- ☑️ Add priority sorting of actions

v1.0
---
- ✅☑️ Add vision library for YOLO object identification
- ✅ Add stabalization check and ui
- ✅ Move to Snap chat UI
- ✅ Add training screen, need to include upload image & "other" item entry
- ✅ Add action table, include settings to select default behavior + Shortcut name
- ✅ Add text OCR features

Stucture
----------

UI : Direct feedback of vision processing, predicted action shown at rest (ie,. action buttons)

- User quickly starts up app, should see real-time feedback on visual scanning (ie, both text rectangles and YOLO boxes).
- Stability indicators should show the focus and trigger second-level of recognition (ie., OCR within field of view, object specific action)
- Multi-level HUD includes a complex stack :
    1. Navigation buttons, Snapchat navigation methods
    2. Action buttons with detailed text / object recognition prompt (ie, "Launch Map App?")
    3. Text rectangle feeback, realtime (15fps?) 
    4. YOLO object detection feedback, realtime (10 fps?)
    5. UPC/QR code feedback, only upon stability? (1 fps?)
    6. Camera preview, realtime (30 fps?)

Vision : 
- Built in CoreML TextRectangle recognition is the highest priority
- Built in CoreVision ObjectTranslation (stability) is the second highest priority
- Google ML Kit based TextRecognition is medium priority
- CoreML based ObjectDection YOLO is lower priority

Recommendation : 
- Could be CoreML based (table based prediction), but use heuristics for now
- Recommendation / recognition priority can be set by users in ActionViewController
