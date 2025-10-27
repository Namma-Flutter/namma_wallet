import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:namma_wallet/src/features/ai/fallback-parser/application/model_download_repo.dart';
import 'package:namma_wallet/src/features/ai/fallback-parser/domain/constants.dart';
import 'package:namma_wallet/src/features/ai/fallback-parser/domain/enums/model_configs.dart';

/// Class [ModelDownloadTile] is a Widget for downloading the model
/// from the
class ModelDownloadTile extends StatefulWidget {
  ///
  const ModelDownloadTile({
    required this.model,
    super.key,
  });

  ///
  final Model model;

  @override
  State<ModelDownloadTile> createState() => _ModelDownloadTileState();
}

class _ModelDownloadTileState extends State<ModelDownloadTile> {
  late ModelDownloadService _downloadService;
  bool _needToDownload = true;
  double _progress = 0.0;
  String _token = '';

  @override
  void initState() {
    super.initState();
    _downloadService = ModelDownloadService(
      modelUrl: widget.model.url,
      modelFilename: widget.model.filename,
      licenseUrl: widget.model.licenseUrl,
    );
    _initialize();
  }

  Future<void> _initialize() async {
    _token = AIConstants.huggingFaceKey;
    _needToDownload = !(await _downloadService.checkModelExistence(_token));
    setState(() {});
  }

  Future<void> _downloadModel() async {
    try {
      await _downloadService.downloadModel(
        token: widget.model.needsAuth ? _token : '',
        onProgress: (progress) {
          setState(() {
            _progress = progress;
          });
        },
      );
      setState(() {
        _needToDownload = false;
      });
    } on Exception catch (e, s) {
      if (kDebugMode) {
        print('Download failed: $e\n$s');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to download model: $e')),
        );
      }
    } finally {
      setState(() {
        _progress = 0.0;
      });
    }
  }

  Future<void> _deleteModel() async {
    await _downloadService.deleteModel();
    setState(() {
      _needToDownload = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.psychology, color: Colors.deepPurple, size: 32),
      title: Text('AI Magic (${widget.model.name})'),
      subtitle: _progress > 0.0
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Downloading: ${_progress.toStringAsFixed(1)}%'),
                LinearProgressIndicator(value: _progress / 100.0),
              ],
            )
          : (_needToDownload
              ? const Text('Model not available')
              : const Text('Model ready to use')),
      trailing: _progress > 0.0
          ? const SizedBox(
              width: 24, height: 24, child: CircularProgressIndicator())
          : (_needToDownload
              ? IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: _downloadModel,
                )
              : const Icon(Icons.check_circle, color: Colors.green, size: 28)),
      onTap: () {
        if (_needToDownload) {
          _downloadModel();
        } else {
          _deleteModel();
        }
      },
    );
  }
}
