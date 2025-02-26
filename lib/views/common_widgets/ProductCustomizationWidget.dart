import 'package:cubes_n_slice/constants/assets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/dto/product.dart';
import 'dropDownComponent.dart';

class ProductCustomizationWidget extends StatefulWidget {
  final Product product;
  final Function(double, double, WeightWithPrice, Map<String, String>, int)
      onPricesChanged;
  const ProductCustomizationWidget({
    super.key,
    required this.product,
    required this.onPricesChanged,
  });

  @override
  _ProductCustomizationWidgetState createState() =>
      _ProductCustomizationWidgetState();
}

class _ProductCustomizationWidgetState
    extends State<ProductCustomizationWidget> {
  WeightWithPrice? selectedWeight;
  Map<String, String> selectedSpecifications = {};
  Map<String, Map<String, dynamic>> selectedSpecificationDetails = {};
  double regularPrice = 0;
  double specialPrice = 0;
  double grandTotalRegularPrice = 0;
  double grandTotalSpecialPrice = 0;
  int choosenQuantity = 1;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildWeightDropdown(),
        const SizedBox(height: 14),
        _buildSpecificationsDropdowns(),
        const SizedBox(
          height: 14,
        ),
        _buildQuantitySelector(),
        const SizedBox(height: 14),
        _buildPriceAndClearButton(),
      ],
    );
  }

  Widget _buildWeightDropdown() {
    if (widget.product.availableWeightsWithPrice == null ||
        widget.product.availableWeightsWithPrice!.isEmpty) {
      return const SizedBox();
    }

    return DropdownFieldComponent(
      disableDropdown: false,
      key: Key(
          'dropdown_${selectedWeight?.value ?? 'initial'}_${selectedWeight?.measureType ?? 'initial'}'),
      needOptionInModal: true,
      items: widget.product.availableWeightsWithPrice!
          .map((e) => "${e.value} ${e.measureType}")
          .toList(),
      labelText: "Weight",
      hintText: "Choose a Weight",
      value: selectedWeight != null
          ? "${selectedWeight!.value} ${selectedWeight!.measureType}"
          : null,
      onChanged: _onWeightChanged,
    );
  }

  Widget _buildSpecificationsDropdowns() {
    if (widget.product.specifications == null ||
        widget.product.specifications!.isEmpty) {
      return const SizedBox();
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final specification = widget.product.specifications![index];
        return _buildSpecificationDropdown(specification, index);
      },
      separatorBuilder: (context, index) => const SizedBox(height: 14),
      itemCount: widget.product.specifications!.length,
    );
  }

  Widget _buildSpecificationDropdown(Specification specification, int index) {
    final isDisabled = selectedWeight == null ||
        (index > 0 &&
            (selectedSpecifications[widget
                        .product.specifications![index - 1].specification] ==
                    null ||
                selectedSpecifications[widget
                        .product.specifications![index - 1].specification]!
                    .isEmpty));

    return DropdownFieldComponent(
      disableDropdown: isDisabled,
      key: ValueKey(selectedSpecifications[specification.specification]),
      needOptionInModal: true,
      items: specification.options?.map((e) => e.option ?? "").toList() ?? [],
      labelText: specification.specification!.capitalize,
      hintText: "Choose ${specification.specification!.capitalize}",
      value: selectedSpecifications[specification.specification],
      onChanged: (value) => _onSpecificationChanged(specification, value),
    );
  }

  Widget _buildPriceAndClearButton() {
    if (selectedWeight == null && selectedSpecificationDetails.isEmpty) {
      return const SizedBox();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (regularPrice > specialPrice)
              Text(
                '₹${regularPrice.toStringAsFixed(2)}',
                style: GoogleFonts.firaSans(
                  fontSize: 14,
                  decoration: TextDecoration.lineThrough,
                  color: Colors.grey,
                ),
              ),
            const SizedBox(
              width: 10,
            ),
            Text(
              '₹${specialPrice.toStringAsFixed(2)}',
              style: GoogleFonts.firaSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: regularPrice > specialPrice ? Colors.red : Colors.black,
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: _clearSelections,
          child: Row(
            children: [
              const Icon(Icons.close, color: Colors.black),
              const SizedBox(width: 4),
              Text('Clear',
                  style:
                      GoogleFonts.firaSans(color: Colors.black, fontSize: 16)),
            ],
          ),
        ),
      ],
    );
  }

  void _onWeightChanged(String? value) {
    if (value != null) {
      final selectedOption =
          widget.product.availableWeightsWithPrice!.firstWhere(
        (e) => "${e.value} ${e.measureType}" == value,
        orElse: () => WeightWithPrice(),
      );

      setState(() {
        selectedWeight = selectedOption;
        _recalculatePrice();
      });
    }
  }

  void _onSpecificationChanged(Specification specification, String? value) {
    if (value != null) {
      final selectedOption = specification.options?.firstWhere(
        (option) => option.option == value,
        orElse: () => Option(),
      );

      setState(() {
        selectedSpecifications[specification.specification!] = value;
        selectedSpecificationDetails[specification.specification!] = {
          'id': selectedOption?.id ?? '',
          'option': selectedOption?.option ?? "",
          'amount': selectedOption?.amount ?? '',
        };
        _recalculatePrice();
      });
    }
  }

  void _recalculatePrice() {
    double baseRegularPrice =
        double.tryParse(selectedWeight?.price ?? '0') ?? 0.0;
    double baseSpecialPrice =
        double.tryParse(selectedWeight?.specialPrice ?? '0') ??
            baseRegularPrice;
    double additionalAmount = 0.0;

    selectedSpecificationDetails.forEach((key, value) {
      additionalAmount += double.tryParse(value['amount'] ?? '0') ?? 0.0;
    });
    setState(() {
      regularPrice = baseRegularPrice + additionalAmount;
      specialPrice = baseSpecialPrice + additionalAmount;
      grandTotalSpecialPrice = specialPrice * choosenQuantity;
      grandTotalRegularPrice = regularPrice * choosenQuantity;
      widget.onPricesChanged(grandTotalRegularPrice, grandTotalSpecialPrice,
          selectedWeight!, selectedSpecifications, choosenQuantity);
    });
  }

  Widget _buildQuantitySelector() {
    if (selectedWeight == null && selectedSpecificationDetails.isEmpty) {
      return const SizedBox();
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xffE9F5FA),
            borderRadius: BorderRadius.circular(24),
          ),
          alignment: Alignment.bottomRight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildQuantityButton(Assets.imagesRemoveIcon, _decrementQuantity),
              const SizedBox(width: 8),
              Text(
                choosenQuantity.toString(),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              _buildQuantityButton(Assets.imagesAddIcon, _incrementQuantity),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityButton(String image, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Image.asset(
          image,
          width: 28,
          height: 28,
        ),
      ),
    );
  }

  void _incrementQuantity() {
    setState(() {
      grandTotalSpecialPrice = specialPrice * choosenQuantity;
      grandTotalRegularPrice = regularPrice * choosenQuantity;
      choosenQuantity++;
    });
    widget.onPricesChanged(grandTotalRegularPrice, grandTotalSpecialPrice,
        selectedWeight!, selectedSpecifications, choosenQuantity);
  }

  void _decrementQuantity() {
    if (choosenQuantity > 1) {
      setState(() {
        grandTotalSpecialPrice = specialPrice * choosenQuantity;
        grandTotalRegularPrice = regularPrice * choosenQuantity;
        choosenQuantity--;
        widget.onPricesChanged(grandTotalRegularPrice, grandTotalSpecialPrice,
            selectedWeight!, selectedSpecifications, choosenQuantity);
      });
    }
  }

  void _clearSelections() {
    setState(() {
      selectedWeight = null;
      selectedSpecifications.clear();
      selectedSpecificationDetails.clear();
      regularPrice = 0;
      grandTotalRegularPrice = 0;
      grandTotalSpecialPrice = 0;
      specialPrice = 0;
      choosenQuantity = 1;
      selectedWeight = null;
      selectedSpecifications.clear();
      widget.onPricesChanged(grandTotalRegularPrice, grandTotalSpecialPrice,
          selectedWeight!, selectedSpecifications, choosenQuantity);
    });
  }
}
