<!-- Type your summary here -->
## dfd_Document


### Summury
| |
| -------- |
|[.buildFromTemplate(name : Text; templateParam : Variant; data : Object; optionText : Text; options : Object) : cs.dfd_DocumentEntity](#-buildfromtemplate-) <br> creates a dynamic document from a predefined template.|
|[.buildFromTemplateOnServer(name : Text; templateParam : Variant; data : Object; optionText : Text; options : Object) : cs.dfd_DocumentEntity](#-buildfromtemplateonserver-) <br>a wrapper that allows the ``buildFromTemplate`` function to be called on the server side.|
|[.print(document : cs.dfd_DocumentEntity)](#-print-) <br>prints a document using predefined or user-specified configurations.|
|[.printOnServer(document : cs.dfd_DocumentEntity)](#-printonserver-) <br>a wrapper method used to trigger the printing of a document directly on the server.|


<!--   buildFromTemplate *********************   -->
## .buildFromTemplate

### .buildFromTemplate(name : Text; templateParam : Variant; data : Object; optionText : Text; options : Object) : cs.dfd_DocumentEntity

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| name  | Text  | <img src="DocImages\arrowRight.png"  height="25" align="center" /> | The name of the document. |
| templateParam  | Variant  | <img src="DocImages\arrowRight.png"  height="25" align="center" /> | A flexible parameter used to define template-specific input (can be text or object) |
| data  | Object  | <img src="DocImages\arrowRight.png"  height="25" align="center" /> | An object containing the data to be injected into the template. |
| optionText  | Text  | <img src="DocImages\arrowRight.png"  height="25" align="center" /> | String to determine which specific actions should be triggered during document generation, such as showing a print preview or generating a PDF preview. |
| options  | Object  | <img src="DocImages\arrowRight.png"  height="25" align="center" /> | An object that holds various customization or configuration options for the generation process. |


#### Description

``buildFromTemplate()`` is a local function designed to create a dynamic document from a predefined template. It automates the generation of structured documents such as invoices, reports, quotes, purchase orders, etc., by injecting specific input data.

The following is a step-by-step breakdown of how it works and what it offers:



##### Context Initialization

An internal $context object is first created and initialized with default display and formatting settings, including:

- Zoom level set to 100%.
- Document orientation set to portrait.
- Rulers visibility disabled.
- Paper format set to "A4" by default from a list of available formats.
  

> These default values serve as a base configuration. However, if the selected template contains specific settings (e.g., custom paper format, print options), they are extracted from the template and copied into the document, overriding the defaults to ensure consistency with the template's predefined structure.

##### Creating a New Document Instance

 A new empty document is created (ds.dfd_Document.new()), which will be configured and populated during the process. The document's name is set from the `name` parameter.


##### Loading the Template
 Based on the type of `templateParam` (text or object), the function loads the corresponding template:

- If `templateParam` is a text string, it is used to query the database for the matching template by name.
- If `templateParam` is already a template object, it is directly assigned to the document.

The loaded template contains layout, styles, and placeholders for dynamic content.


##### Handling Print and Export Options
 The ``options`` object is used to configure various optional parameters, such as:
- **printPreview:** whether to show a print preview.
- **printNbCopies:** number of copies to print.
- **printSettings:** advanced print settings.
- **pdfPrinter:** name of the PDF printer driver.
- **pdfPath:** file path for saving the PDF.
- **pdfDocumentName:** name of the generated PDF file.
  
These options are stored in the internal document settings.

>The paper format used in the document is selected either from the provided options or from the settings defined within the template. The function checks the available list of supported paper formats—such as A4, A3, and others—and applies the one that best matches the chosen configuration.

The ``data`` object passed into the function is assigned to the ``variableItems`` property of the document. This allows the template to be automatically filled with dynamic values, making each document uniquely tailored to its context.

The ``optionText`` parameter can include several instructions, separated by semicolons—for example: "print;pdf;save". Based on these instructions, the function performs actions such as generating a preview for print or PDF output and saving the document automatically if required.

Once all settings have been applied and the processing is complete, the function returns a fully prepared document instance (**cs.dfd_DocumentEntity**). This document is now ready to be displayed, printed, saved, or exported as needed



#### Exemple

This example demonstrates how to:

- Create a data object with staff information.
- Define options for document rendering.
- Generate a printable document from a predefined template using dynamic content.

```4d	
$data:=New object()
$data.staffs:=ds.Staff.all().orderBy("fullName").toCollection("fullName,department.name")

$options:=New object()
$options.printPreview:=True

$document:=ds.dfd_Document.buildFromTemplate("staffList"; "StaffList"; $data; "print"; $options)
```


<!--   buildFromTemplateOnServer *********************   -->
## .buildFromTemplateOnServer

### .buildFromTemplateOnServer(name : Text; templateParam : Variant; data : Object; optionText : Text; options : Object) : cs.dfd_DocumentEntity

The ``buildFromTemplateOnServer`` function is a wrapper that allows the ``buildFromTemplate`` function to be called on the server side, ensuring that the document generation process occurs in a controlled environment.

It forwards all received parameters to ``buildFromTemplate`` by dynamically collecting and passing them as a collection.

The ``buildFromTemplateOnServer`` function is useful when you want to delegate document generation to the server side without duplicating logic. It:

- Accepts the same inputs as `buildFromTemplate`,
- Dynamically gathers them,
- Forwards them to the main method,
- Returns the resulting document.

This ensures clean code reuse and centralized logic, with the added benefit of server-side execution.


<!--   print($document : cs.dfd_DocumentEntity) *********************   -->
## .print

### .print(document : cs.dfd_DocumentEntity)

| Parameter    | Type |  |Description|
| -------- | ------- | ------- | ------- |
| document  | Text  | <img src="DocImages\arrowRight.png"  height="25" align="center" /> | The document object to be printed. |




#### Description

The ``print()`` function is designed to render and print a document using predefined or user-specified configurations. It prepares the print context (paper format, orientation, number of copies, etc.) and then delegates the actual rendering and printing to a method with the print flag.


The function begins by initializing a new object named ``$context``, which serves as the container for all the printing parameters. It sets default values such as a 100% zoom level, portrait orientation (portrait = 1), landscape disabled (landscape = 0), and rulers turned off. 
It also initializes a nested paper object within the context.The default paper format is set to "A4".

Next, the document to be printed is assigned to the context via ``$context.document:=$document``. This document should already contain metadata and user-defined settings, including printing preferences stored in the **moreData.settings** property.

The function then attempts to determine the appropriate paper format by looking for a format value in the document’s settings. If not found, it falls back to the default "A4" format.

The number of copies to print is also extracted from the document’s settings. If the specified number of copies is missing, invalid, or set to zero, the function defaults this value to 1, ensuring that at least one copy is printed.

Finally, the prepared context is passed to the ``cs.dfd_panel_document.me.redraw_preview()`` method with the "--print" argument. This method is responsible for rendering the document visually based on the provided context and initiating the actual printing process.




<!--   printOnServer *********************   -->
## .printOnServer

### .printOnServer(document : cs.dfd_DocumentEntity)

The ``printOnServer()`` function is a wrapper method used to trigger the printing of a document directly on the server. It simply delegates the task to the ``print()`` method defined in the same context or class.

This function is particularly useful in client-server environments, where print jobs need to be executed on the server for consistency, access to server-side printers, or centralized document management.



