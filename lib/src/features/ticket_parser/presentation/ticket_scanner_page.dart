import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:namma_wallet/src/features/pdf_extract/application/pdf_service.dart';
import 'package:namma_wallet/src/features/sms_extract/application/sms_service.dart';
import 'package:namma_wallet/src/features/ticket_parser/tnstc/application/tnstc_pdf_parser.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  int currentIndex = 0;
  MobileScannerController cameraController = MobileScannerController();
  TextEditingController textController = TextEditingController();
  String? uploadedFileName;
  String? uploadedFilePath;
  String? qrResult;
  bool isScanning = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    cameraController.dispose();
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            // Top navigation bar
            const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.arrow_back, color: Colors.blue, size: 24),
                  Icon(Icons.more_horiz, color: Colors.blue, size: 24),
                ],
              ),
            ),
            // Main content area
            Expanded(
              child: _buildCurrentScreen(),
            ),
            // Bottom navigation with three buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildBottomButton(
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    isSelected: currentIndex == 0,
                    onTap: () {
                      if (currentIndex == 0) {
                        // leaving camera tab → stop camera
                        cameraController.stop();
                        isScanning = false;
                      }
                      setState(() => currentIndex = 0);
                      if (currentIndex == 0) {
                        _startScanning();
                      }
                    },
                  ),
                  _buildBottomButton(
                    icon: Icons.text_fields,
                    label: 'Text',
                    isSelected: currentIndex == 1,
                    onTap: () {
                      if (currentIndex == 0) {
                        cameraController.stop();
                        isScanning = false;
                      }
                      setState(() => currentIndex = 1);
                    },
                  ),
                  _buildBottomButton(
                    icon: Icons.attach_file,
                    label: 'Upload',
                    isSelected: currentIndex == 2,
                    onTap: () {
                      if (currentIndex == 0) {
                        cameraController.stop();
                        isScanning = false;
                      }
                      setState(() => currentIndex = 2);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[600],
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.blue : Colors.grey[600],
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentScreen() {
    switch (currentIndex) {
      case 0:
        return _buildCameraScreen();
      case 1:
        return _buildTextScreen();
      case 2:
        return _buildUploadScreen();
      default:
        return _buildCameraScreen();
    }
  }

  Widget _buildCameraScreen() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: Stack(
                  children: [
                    MobileScanner(
                      controller: cameraController,
                      onDetect: _onQRCodeDetected,
                    ),
                    // Custom overlay for scanning area
                    Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.6,
                        height: MediaQuery.of(context).size.width * 0.6,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.blue,
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Stack(
                          children: [
                            // Corner brackets
                            Positioned(
                              top: -2,
                              left: -2,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                  border: Border(
                                    left: BorderSide(
                                        color: Colors.blue, width: 4),
                                    top: BorderSide(
                                        color: Colors.blue, width: 4),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: -2,
                              right: -2,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                  border: Border(
                                    right: BorderSide(
                                        color: Colors.blue, width: 4),
                                    top: BorderSide(
                                        color: Colors.blue, width: 4),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: -2,
                              left: -2,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                  border: Border(
                                    left: BorderSide(
                                        color: Colors.blue, width: 4),
                                    bottom: BorderSide(
                                        color: Colors.blue, width: 4),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: -2,
                              right: -2,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                  border: Border(
                                    right: BorderSide(
                                        color: Colors.blue, width: 4),
                                    bottom: BorderSide(
                                        color: Colors.blue, width: 4),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Scanning animation line
                    if (isScanning)
                      Center(
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.6,
                          height: 2,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.blue,
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (qrResult != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.qr_code_scanner, color: Colors.blue[800]),
                      const SizedBox(width: 8),
                      Text(
                        'QR Code Result:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: SelectableText(
                      qrResult!,
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: qrResult!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Copied to clipboard!')),
                          );
                        },
                        icon: const Icon(Icons.copy, size: 16),
                        label: const Text('Copy'),
                      ),
                      TextButton.icon(
                        onPressed: _clearQRResult,
                        icon: const Icon(Icons.clear, size: 16),
                        label: const Text('Clear'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      isScanning ? 'Scanning...' : 'Start Scanning',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  onPressed: _toggleFlashlight,
                  icon: Icon(
                    Icons.flash_on,
                    color: Colors.blue[800],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextScreen() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.blue, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: textController,
                maxLines: null,
                expands: true,
                decoration: InputDecoration(
                  hintText: 'Paste or type your text here...',
                  hintStyle: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 16,
                  ),
                  border: InputBorder.none,
                ),
                style: const TextStyle(fontSize: 16),
                textAlignVertical: TextAlignVertical.top,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _pasteFromClipboard,
                  icon: const Icon(Icons.content_paste),
                  label: const Text('Paste from Clipboard'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[100],
                    foregroundColor: Colors.blue[800],
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _clearText,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[100],
                  foregroundColor: Colors.red[800],
                  padding: const EdgeInsets.all(12),
                ),
                child: const Icon(Icons.clear),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              final ticket = SMSService().parseTicket(textController.text);
              print('Parsed Ticket: $ticket');
            },
            child: Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'Process Text',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadScreen() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _pickFile,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CustomPaint(
                  painter: DashedBorderPainter(),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          uploadedFileName != null
                              ? Icons.description
                              : Icons.cloud_upload_outlined,
                          color: Colors.blue,
                          size: 60,
                        ),
                        const SizedBox(height: 20),
                        if (uploadedFileName != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue[200]!),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.check_circle,
                                    color: Colors.green, size: 24),
                                const SizedBox(height: 8),
                                Text(
                                  'File Uploaded:',
                                  style: TextStyle(
                                    color: Colors.blue[800],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  uploadedFileName!,
                                  style: TextStyle(
                                    color: Colors.blue[700],
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.blue, width: 2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.upload,
                                    color: Colors.blue, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Upload File',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tap to upload PDF, JPG, PNG files',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Supported: PDF, JPG, PNG',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () async {
              if (uploadedFilePath != null) {
                try {
                  // Extract PDF text using Syncfusion
                  final pdfFile = File(uploadedFilePath!);
                  final extractedText = PDFService().extractTextFrom(pdfFile);
                  
                  // Parse ticket using extracted text
                  final ticket = TNSTCPDFParser.parseTicket(extractedText);
                  print('Extracted Text: $extractedText');
                  print('Parsed Ticket: $ticket');
                  
                  // Show success message
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('PDF processed successfully!')),
                    );
                  }
                } catch (e) {
                  print('Error processing PDF: $e');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error processing PDF: $e')),
                    );
                  }
                }
              }
            },
            child: Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  uploadedFileName != null
                      ? 'Process File'
                      : 'Choose File to Upload',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRCodeDetected(BarcodeCapture capture) {
    final barcodes = capture.barcodes;
    if (barcodes.isNotEmpty && barcodes.first.displayValue != null) {
      final scannedData = barcodes.first.displayValue!;
      if (qrResult != scannedData) {
        setState(() {
          qrResult = scannedData;
          isScanning = false;
        });

        print('QR Code Scanned: $scannedData');

        // Vibrate on successful scan (optional)
        HapticFeedback.lightImpact();

        // Optional: Stop scanning briefly
        cameraController.stop();

        // Resume scanning after a delay
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            cameraController.start();
            setState(() {
              isScanning = true;
            });
          }
        });
      }
    }
  }

  void _startScanning() {
    cameraController.start();
    setState(() {
      isScanning = true;
    });
  }

  void _clearQRResult() {
    setState(() {
      qrResult = null;
    });
    _startScanning();
  }

  void _toggleFlashlight() {
    cameraController.toggleTorch();
  }

  Future<void> _pasteFromClipboard() async {
    try {
      final data = await Clipboard.getData('text/plain');
      if (data != null && data.text != null) {
        setState(() {
          textController.text = data.text!;
        });
        print('Text pasted from clipboard: ${data.text}');
      }
    } catch (e) {
      print('Error pasting from clipboard: $e');
    }
  }

  void _clearText() {
    setState(() {
      textController.clear();
    });
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        final file = result.files.first;
        setState(() {
          uploadedFileName = file.name;
          uploadedFilePath = file.path;
        });
        print('File selected: ${file.name}');
        print('File path: ${file.path}');
        print('File size: ${file.size} bytes');
      }
    } catch (e) {
      print('Error picking file: $e');
    }
  }
}

class DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashWidth = 8.0;
    const dashSpace = 4.0;

    // Top border
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(
            startX + dashWidth > size.width ? size.width : startX + dashWidth,
            0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }

    // Right border
    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width, startY),
        Offset(
            size.width,
            startY + dashWidth > size.height
                ? size.height
                : startY + dashWidth),
        paint,
      );
      startY += dashWidth + dashSpace;
    }

    // Bottom border
    startX = size.width;
    while (startX > 0) {
      canvas.drawLine(
        Offset(startX, size.height),
        Offset(startX - dashWidth < 0 ? 0 : startX - dashWidth, size.height),
        paint,
      );
      startX -= dashWidth + dashSpace;
    }

    // Left border
    startY = size.height;
    while (startY > 0) {
      canvas.drawLine(
        Offset(0, startY),
        Offset(0, startY - dashWidth < 0 ? 0 : startY - dashWidth),
        paint,
      );
      startY -= dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
