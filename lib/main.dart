import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Text Extraction Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Text Extraction'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FlatButton(
              child: Text(
                'Extract all text',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: _extractAllText,
              color: Colors.blue,
            ),
            FlatButton(
              child: Text(
                'Extract text with predefined bounds',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: _extractTextWithBounds,
              color: Colors.blue,
            ),
            FlatButton(
              child: Text(
                'Extract text from a specific page',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: _extractTextFromSpecificPage,
              color: Colors.blue,
            ),
            FlatButton(
              child: Text(
                'Extract text from a range of pages',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: _extractTextFromRangeOfPage,
              color: Colors.blue,
            ),
            FlatButton(
              child: Text(
                'Extract text with font and style information',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: _extractTextWithFontAndStyleInformation,
              color: Colors.blue,
            )
          ],
        ),
      ),
    );
  }

  Future<void> _extractAllText() async {
    //Load the existing PDF document.
    PdfDocument document =
        PdfDocument(inputBytes: await _readDocumentData('pdf_succinctly.pdf'));

    //Create the new instance of the PdfTextExtractor.
    PdfTextExtractor extractor = PdfTextExtractor(document);

    //Extract all the text from the document.
    String text = extractor.extractText();

    //Display the text.
    _showResult(text);
  }

  Future<void> _extractTextWithBounds() async {
    //Load the existing PDF document.
    PdfDocument document =
        PdfDocument(inputBytes: await _readDocumentData('invoice.pdf'));

    //Create the new instance of the PdfTextExtractor.
    PdfTextExtractor extractor = PdfTextExtractor(document);

    //Extract all the text from the particular page.
    List<TextLine> result = extractor.extractTextLines(startPageIndex: 0);

    //Predefined bound.
    Rect textBounds = Rect.fromLTWH(474, 161, 50, 9);

    String invoiceNumber = '';

    for (int i = 0; i < result.length; i++) {
      List<TextWord> wordCollection = result[i].wordCollection;
      for (int j = 0; j < wordCollection.length; j++) {
        if (textBounds.overlaps(wordCollection[j].bounds)) {
          invoiceNumber = wordCollection[j].text;
          break;
        }
      }
      if (invoiceNumber != '') {
        break;
      }
    }

    //Display the text.
    _showResult(invoiceNumber);
  }

  Future<void> _extractTextFromSpecificPage() async {
    //Load the existing PDF document.
    PdfDocument document =
        PdfDocument(inputBytes: await _readDocumentData('pdf_succinctly.pdf'));

    //Create the new instance of the PdfTextExtractor.
    PdfTextExtractor extractor = PdfTextExtractor(document);

    //Extract all the text from the first page of the PDF document.
    String text = extractor.extractText(startPageIndex: 2);

    //Display the text.
    _showResult(text);
  }

  Future<void> _extractTextFromRangeOfPage() async {
    //Load the existing PDF document.
    PdfDocument document =
        PdfDocument(inputBytes: await _readDocumentData('pdf_succinctly.pdf'));

    //Create the new instance of the PdfTextExtractor.
    PdfTextExtractor extractor = PdfTextExtractor(document);

    //Extract all the text from the first page to 3rd page of the PDF document.
    String text = extractor.extractText(startPageIndex: 0, endPageIndex: 2);

    //Display the text.
    _showResult(text);
  }

  Future<void> _extractTextWithFontAndStyleInformation() async {
    //Load the existing PDF document.
    PdfDocument document =
        PdfDocument(inputBytes: await _readDocumentData('invoice.pdf'));

    //Create the new instance of the PdfTextExtractor.
    PdfTextExtractor extractor = PdfTextExtractor(document);

    //Extract all the text from specific page.
    List<TextLine> result = extractor.extractTextLines(startPageIndex: 0);

    //Draw rectangle..
    for (int i = 0; i < result.length; i++) {
      List<TextWord> wordCollection = result[i].wordCollection;
      for (int j = 0; j < wordCollection.length; j++) {
        if ('2058557939' == wordCollection[j].text) {
          //Get the font name.
          String fontName = wordCollection[j].fontName;
          //Get the font size.
          double fontSize = wordCollection[j].fontSize;
          //Get the font style.
          List<PdfFontStyle> fontStyle = wordCollection[j].fontStyle;
          //Get the text.
          String text = wordCollection[j].text;
          String fontStyleText = '';
          for (int i = 0; i < fontStyle.length; i++) {
            fontStyleText += fontStyle[i].toString() + ' ';
          }
          fontStyleText = fontStyleText.replaceAll('PdfFontStyle.', '');
          _showResult(
              'Text : $text \r\n Font Name: $fontName \r\n Font Size: $fontSize \r\n Font Style: $fontStyleText');
          break;
        }
      }
    }
    //Dispose the document.
    document.dispose();
  }

  Future<List<int>> _readDocumentData(String name) async {
    final ByteData data = await rootBundle.load('assets/$name');
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }

  void _showResult(String text) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Extracted text'),
            content: Scrollbar(
              child: SingleChildScrollView(
                child: Text(text),
                physics: BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
              ),
            ),
            actions: [
              FlatButton(
                child: Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }
}
