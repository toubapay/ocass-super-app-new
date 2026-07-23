import 'package:get/get.dart';
import 'package:demandium/util/core_export.dart';

class LocationSearchDialog extends StatefulWidget {
  final GoogleMapController? Function() getMapController;
  final String? pickedLocation;
  final Widget? child;

  const LocationSearchDialog({
    super.key,
    required this.getMapController,
    this.pickedLocation,
    this.child,
  });

  @override
  State<LocationSearchDialog> createState() => _LocationSearchDialogState();
}

class _LocationSearchDialogState extends State<LocationSearchDialog> {
  final SearchController controller = SearchController();
  String? _searchingWithQuery;
  late Iterable<Widget> _lastOptions = <Widget>[];
  List<PredictionModel> _predictionList = [];
  List<String> _predictList = <String>[];

  @override
  void initState() {
    super.initState();
    _updateControllerText();
  }

  @override
  void didUpdateWidget(LocationSearchDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pickedLocation != widget.pickedLocation) {
      _updateControllerText();
    }
  }

  void _updateControllerText() {
    if (widget.pickedLocation != null && widget.pickedLocation!.isNotEmpty) {
      controller.text = widget.pickedLocation!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ServiceLocationController>(
      builder: (lController) {
        return SearchAnchor(
          searchController: controller,
          viewSurfaceTintColor: Theme.of(context).cardColor,
          isFullScreen: false,
          viewLeading: IconButton(
            onPressed: () => controller.closeView(''),
            icon: const Icon(Icons.arrow_back),
          ),
          viewTrailing: [
            IconButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  controller.text = '';
                } else {
                  controller.closeView('');
                }
              },
              icon: const Icon(Icons.clear),
            ),
          ],
          viewOnChanged: (value) async {
            // Handle view changes if needed
          },
          viewConstraints: const BoxConstraints(minHeight: 100, maxHeight: 300),
          builder: (BuildContext context, SearchController controller) {
            return widget.child ??
                Container(
                  height: 50,
                  width: 500,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeSmall,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 25,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Expanded(
                        child: Text(
                          controller.text.isNotEmpty
                              ? controller.text
                              : 'search_location'.tr,
                          style: robotoRegular.copyWith(
                            color: controller.text.isEmpty
                                ? Theme.of(context).disabledColor
                                : Theme.of(context).textTheme.bodyMedium!.color,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.search),
                    ],
                  ),
                );
          },
          suggestionsBuilder:
              (BuildContext context, SearchController controller) async {
                _searchingWithQuery = controller.text;
                final List<String> options = (await _search(
                  _searchingWithQuery!,
                  lController,
                )).toList();

                if (_searchingWithQuery != controller.text) {
                  return _lastOptions;
                }

                _lastOptions = List<ListTile>.generate(options.length, (
                  int index,
                ) {
                  final String location = options[index];
                  return ListTile(
                    leading: const Icon(Icons.location_on),
                    title: Text(location),
                    onTap: () async {
                      final int selectedIndex = _predictList.indexOf(location);
                      final PredictionModel suggestion =
                          _predictionList[selectedIndex];

                      Get.find<ServiceLocationController>().setLocation(
                        suggestion.placeId ??
                            suggestion.placePrediction!.placeId!,
                        suggestion.description ??
                            suggestion.placePrediction?.text?.text ??
                            "",
                        widget.getMapController(),
                      );

                      controller.closeView(location);
                    },
                  );
                });

                return _lastOptions;
              },
        );
      },
    );
  }

  Future<Iterable<String>> _search(
    String query,
    ServiceLocationController locationController,
  ) async {
    _predictionList = await locationController.searchLocation(context, query);

    if (query == '') {
      return const Iterable<String>.empty();
    }

    _predictList = [];
    for (var prediction in _predictionList) {
      _predictList.add(
        prediction.description ?? prediction.placePrediction?.text?.text ?? '',
      );
    }

    if (_predictList.isEmpty) {
      _predictList.add('no_address_found'.tr);
    }

    return _predictList;
  }
}
