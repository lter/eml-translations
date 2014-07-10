FGDC -> EML 2.1
==================

Instructions for using these files:

You need to place the arcgisfgdc_intermideate.xml file under the metadata\translator folder for you arcgis software.  
example: C:\Program Files (x86)\ArcGIS\Desktop10.1\Metadata\Translator

The  arcgisfgdc_intermideate.xsl file is place under the metadata\translator\transforms folder:
example: C:\Program Files (x86)\ArcGIS\Desktop10.1\Metadata\Translator\Transforms

Once you have placed the files in the appropriate location, you will want to export your arcgis metadata and select the 
arcgisfgdc_test.xml file instead of the default.   (through  the arcgis metadata export tools.)

The easiest way to find the file is to click on the default in the tab, and add _test to the file name of the default.

You can also place the fgdc-eml2.1.xsl to the same folder as the arcgis xsl file
(metadata\translator\transforms)  and the fgdc-eml2.1.xml file would go in the folder (metadata\translator). 
Now you can perform a transformation to eml using the tools in arcgis catalog/toolbox.  Remember if you edit the .xsl stylesheet 
with your own custom site information, and you change the name of the file, you need to update the appropriate .xml file so the tool will continue to work.

Good Luck

Theresa Valentine
February 26, 2013

