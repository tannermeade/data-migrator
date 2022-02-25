import 'package:data_migrator/domain/data_types/enums.dart';
import 'package:data_migrator/domain/data_types/interfaces/schema_default_value.dart';
import 'package:data_migrator/domain/data_types/interfaces/schema_size.dart';
import 'package:data_migrator/domain/data_types/interfaces/schema_typed.dart';
import 'package:data_migrator/domain/data_types/primitive_types/schema_boolean.dart';
import 'package:data_migrator/domain/data_types/primitive_types/schema_date.dart';
import 'package:data_migrator/domain/data_types/primitive_types/schema_enum.dart';
import 'package:data_migrator/domain/data_types/primitive_types/schema_float.dart';
import 'package:data_migrator/domain/data_types/primitive_types/schema_int.dart';
import 'package:data_migrator/domain/data_types/primitive_types/schema_string.dart';
import 'package:data_migrator/domain/data_types/schema_field.dart';
import 'package:data_migrator/ui/common/alpine/alpine_button.dart';
import 'package:data_migrator/ui/common/alpine/alpine_checkbox.dart';
import 'package:data_migrator/ui/common/alpine/alpine_close_button.dart';
import 'package:data_migrator/ui/common/alpine/alpine_colors.dart';
import 'package:data_migrator/ui/common/alpine/alpine_selection_widget.dart';
import 'package:data_migrator/ui/common/alpine/alpine_switch.dart';
import 'package:data_migrator/ui/common/widgets/primitive_input/float_field.dart';
import 'package:data_migrator/ui/common/widgets/primitive_input/int_field.dart';
import 'package:data_migrator/ui/common/widgets/primitive_input/string_field.dart';
import 'package:data_migrator/ui/common/widgets/tooltip_target.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vrouter/vrouter.dart';

class AddFieldDialog extends StatefulWidget {
  const AddFieldDialog({
    Key? key,
    required this.field,
    this.onAddField,
  }) : super(key: key);

  final SchemaField field;
  final bool Function(SchemaField)? onAddField;

  @override
  _AddFieldDialogState createState() => _AddFieldDialogState();
}

class _AddFieldDialogState extends State<AddFieldDialog> with TickerProviderStateMixin {
  final double width;
  late TabController tabController;
  late TextEditingController _fieldIdController;
  late TextEditingController _defaultValueController;
  late TextEditingController _sizeController;
  late TextEditingController _minController;
  late TextEditingController _maxController;
  final bool showHeaderDivider;
  late SchemaField field;

  _AddFieldDialogState({
    this.width = 600,
    this.showHeaderDivider = true,
  });

  void removeDialog() {
    if (context.vRouter.historyCanBack() && context.vRouter.previousUrl != null) {
      var url = context.vRouter.previousUrl!;
      context.vRouter.historyBack();
      context.vRouter.to(url, isReplacement: true);
    }
  }

  @override
  void initState() {
    field = widget.field;
    _fieldIdController = TextEditingController(text: field.title);
    _initControllers();

    int tabCount = buildTabs().length;
    if (tabCount > 0) {
      tabController = TabController(length: tabCount, vsync: this, initialIndex: _getInitialIndex)
        ..addListener(() {
          _resetDataType();
          setState(() {});
        });
    }
    super.initState();
  }

  void _initControllers() {
    if (field.types.any((type) => type is SchemaDefaultValue)) {
      _defaultValueController = TextEditingController(
          text:
              ((field.types.firstWhere((type) => type is SchemaDefaultValue) as SchemaDefaultValue).defaultValue ?? "")
                  .toString());
    }
    if (field.types.any((type) => type is SchemaSizeInt)) {
      _sizeController = TextEditingController(
          text: ((field.types.firstWhere((type) => type is SchemaSizeInt) as SchemaSizeInt).size ?? 0).toString());
    }
    if (field.types.any((type) => type is SchemaSizeRange)) {
      var type = field.types.firstWhere((type) => type is SchemaSizeRange) as SchemaSizeRange;
      _minController = TextEditingController(text: (type.min ?? 0).toString());
      _maxController = TextEditingController(text: (type.max ?? 0).toString());
    }
  }

  void _resetDataType() {
    switch (tabController.index) {
      case 0:
        field = SchemaField.copyWith(field, types: [SchemaString(type: StringType.text)]);
        break;
      case 1:
        field = SchemaField.copyWith(field, types: [SchemaInt(type: IntType.int)]);
        break;
      case 2:
        field = SchemaField.copyWith(field, types: [SchemaFloat(type: FloatType.float)]);
        break;
      case 3:
        field = SchemaField.copyWith(field, types: [SchemaEnum(elements: [])]);
        break;
      case 4:
        field = SchemaField.copyWith(field, types: [SchemaDate(type: DateType.timestamp)]);
        break;
      case 5:
        field = SchemaField.copyWith(field, types: [SchemaBoolean()]);
        break;
      default:
    }
    _initControllers();
  }

  int get _getInitialIndex {
    switch (field.types.first.runtimeType) {
      case SchemaString:
        return 0;
      case SchemaInt:
        return 1;
      case SchemaFloat:
        return 2;
      case SchemaEnum:
        return 3;
      case SchemaDate:
        return 4;
      case SchemaBoolean:
        return 5;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
      backgroundColor: AlpineColors.background1b,
      child: SizedBox(
        width: width,
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Stack(
                children: [
                  Container(
                    alignment: Alignment.topRight,
                    padding: const EdgeInsets.only(left: 40, top: 35, bottom: 0, right: 40),
                    child: AlpineCloseButton(onTap: () => Navigator.pop(context)),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildHeader(),
                      _buildTabs(),
                      if (showHeaderDivider) Divider(color: AlpineColors.chartLineColor2, thickness: 2),
                      buildBody(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ],
              ),
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: _buildFooter(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    var tabs = buildTabs();
    if (tabs.isEmpty) return const SizedBox();
    return TabBar(
      controller: tabController,
      padding: EdgeInsets.zero,
      labelPadding: EdgeInsets.zero,
      indicatorColor: AlpineColors.textColor1,
      tabs: tabs,
    );
  }

  List<Widget> _buildTypeSelector() {
    List<Enum> enumValues = [];
    switch (tabController.index) {
      case 0:
        enumValues = StringType.values;
        break;
      case 1:
        enumValues = IntType.values;
        break;
      case 2:
        enumValues = FloatType.values;
        break;
      case 4:
        enumValues = DateType.values;
        break;
    }
    return [
      Row(
        children: [
          Text(
            "Type",
            style: TextStyle(
              color: AlpineColors.textColor1,
              fontSize: 16,
              fontWeight: FontWeight.w200,
            ),
          ),
          const SizedBox(width: 5),
          ToolTipTarget(
            showTooltipOnHover: true,
            child: Container(
              width: 15,
              height: 15,
              alignment: Alignment.topCenter,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: AlpineColors.buttonColor2,
              ),
              child: Text("i",
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: "info",
                    color: AlpineColors.background1a,
                  )),
            ),
            toolTip: SizedBox(
              width: 250,
              child: Text(
                "This attribute requires a specific type.",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  color: AlpineColors.background1a,
                ),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 15),
      Container(
        decoration: BoxDecoration(
          color: AlpineColors.textColor1,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        // alignment: Alignment.center,
        child: DropdownButton<Enum>(
          iconEnabledColor: Colors.transparent,
          iconDisabledColor: Colors.transparent,
          focusColor: Colors.transparent,
          dropdownColor: AlpineColors.textColor1,
          value: field.types.first is SchemaTyped ? (field.types.first as SchemaTyped).type : enumValues.first,
          underline: const SizedBox(),
          icon: const SizedBox(),
          hint: Text(
            "No Type Selected",
            style: TextStyle(color: AlpineColors.warningColor),
          ),
          items: enumValues
              .map((e) => DropdownMenuItem<Enum>(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Text(e.name, style: TextStyle(color: AlpineColors.background1a))],
                  ),
                  value: e))
              .toList(),
          onChanged: (Enum? value) {
            if (field.types.first is SchemaTyped && value != null) {
              (field.types.first as SchemaTyped).typeByEnum = value;
              // field = SchemaField.copyWith(field, types: [field.types.first]);
              setState(() {});
            }
          },
        ),
      ),
      const SizedBox(height: 20),
    ];
  }

  // Widget _buildTab(String title) =>
  //     Tab(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w200)));

  // List<Widget> buildTypeTabs() {
  //   switch (tabController.index) {
  //     case 0:
  //       return StringType.values.map((e) => _buildTab(e.name)).toList();
  //     case 1:
  //       return IntType.values.map((e) => _buildTab(e.name)).toList();
  //     case 2:
  //       return FloatType.values.map((e) => _buildTab(e.name)).toList();
  //     case 4:
  //       return DateType.values.map((e) => _buildTab(e.name)).toList();
  //     default:
  //       return [];
  //   }
  // }

  Widget _buildHeader() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 40, top: 35, bottom: 30, right: 40),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: buildHeader(),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: AlpineColors.background2a,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
      ),
      padding: const EdgeInsets.only(top: 25, left: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: buildFooter(),
      ),
    );
  }

  List<Widget> buildFooter() {
    return [
      AlpineButton(
        label: "Add",
        color: AlpineColors.buttonColor2,
        isFilled: true,
        onTap: () {
          if (widget.onAddField != null) {
            bool successful = widget.onAddField!(field);
            if (successful) Navigator.pop(context);
          }
        },
      ),
      const SizedBox(width: 10),
      AlpineButton(
        label: "Back",
        color: AlpineColors.buttonColor2,
        isFilled: false,
        onTap: () => Navigator.pop(context),
      ),
    ];
  }

  List<Widget> buildHeader() {
    return [
      Text(
        "Add Attribute",
        style: TextStyle(
          color: AlpineColors.textColor1,
          fontSize: 20,
          fontWeight: FontWeight.w200,
        ),
      ),
    ];
  }

  List<Widget> buildTabs() {
    return const [
      Tab(child: Text("String", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w200))),
      Tab(child: Text("Integer", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w200))),
      Tab(child: Text("Float", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w200))),
      Tab(child: Text("Enum", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w200))),
      Tab(child: Text("Date", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w200))),
      Tab(child: Text("Boolean", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w200))),
    ];
  }

  Widget buildBody() {
    return Container(
        margin: const EdgeInsets.only(top: 30, bottom: 30),
        padding: const EdgeInsets.only(left: 40, right: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (field.types.first is SchemaTyped) ..._buildTypeSelector(),
            ..._buildAttributeLabel(),
            const SizedBox(height: 30),
            if (field.types.first is SchemaString) ..._buildSize(),
            if ([SchemaInt, SchemaFloat].contains(field.types.first.runtimeType)) ..._buildMinMax(),
            if (field.types.first is SchemaEnum) ..._buildElements(),
            ..._buildRequired(),
            ..._buildArray(),
            ..._buildDefaultValue(),
          ],
        ));
  }

  List<Widget> _buildMinMax() {
    return [
      Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                children: [
                  Text("Min",
                      style: TextStyle(
                        color: AlpineColors.textColor1,
                        fontWeight: FontWeight.w200,
                        fontSize: 16,
                      )),
                  const SizedBox(width: 15),
                  AlpineCheckbox(
                    value: (field.types.first as SchemaSizeRange).min == null,
                    onChanged: (value) {
                      print("min tapped: $value");
                      var emptyVal = field.types.first is SchemaInt ? 0 : 0.0;
                      (field.types.first as SchemaSizeRange).minByDynamic = value != null && value ? null : emptyVal;
                      setState(() {});
                    },
                  ),
                  const SizedBox(width: 5),
                  Text(
                    "No value",
                    style: TextStyle(
                      color: AlpineColors.textColor1,
                      fontSize: 14,
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (field.types.first is SchemaInt)
                IntField(
                  controller: _minController,
                  disabled: (field.types.first as SchemaSizeRange).min == null,
                ),
              if (field.types.first is SchemaFloat)
                FloatField(
                  controller: _minController,
                  disabled: (field.types.first as SchemaSizeRange).min == null,
                ),
            ]),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                children: [
                  Text("Max",
                      style: TextStyle(
                        color: AlpineColors.textColor1,
                        fontWeight: FontWeight.w200,
                        fontSize: 16,
                      )),
                  const SizedBox(width: 15),
                  AlpineCheckbox(
                    key: const Key("addFieldRangeMax"),
                    value: (field.types.first as SchemaSizeRange).max == null,
                    onChanged: (value) {
                      var emptyVal = field.types.first is SchemaInt ? 0 : 0.0;
                      (field.types.first as SchemaSizeRange).maxByDynamic = value != null && value ? null : emptyVal;
                      setState(() {});
                    },
                  ),
                  const SizedBox(width: 5),
                  Text(
                    "No value",
                    style: TextStyle(
                      color: AlpineColors.textColor1,
                      fontSize: 14,
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (field.types.first is SchemaInt)
                IntField(
                  controller: _maxController,
                  disabled: (field.types.first as SchemaSizeRange).max == null,
                ),
              if (field.types.first is SchemaFloat)
                FloatField(
                  controller: _maxController,
                  disabled: (field.types.first as SchemaSizeRange).max == null,
                ),
            ]),
          ),
        ],
      ),
      const SizedBox(height: 30),
    ];
  }

  List<Widget> _buildRequired() {
    return [
      Row(
        children: [
          AlpineSwitch(
            initiallyOn: field.required,
            onChange: (value) => field = SchemaField.copyWith(field, required: value),
          ),
          const SizedBox(width: 15),
          Text("Required", style: TextStyle(color: AlpineColors.textColor1, fontWeight: FontWeight.w200, fontSize: 16)),
          const SizedBox(width: 5),
          ToolTipTarget(
            showTooltipOnHover: true,
            child: Container(
              width: 15,
              height: 15,
              alignment: Alignment.topCenter,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: AlpineColors.buttonColor2,
              ),
              child: Text("i",
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: "info",
                    color: AlpineColors.background1a,
                  )),
            ),
            toolTip: SizedBox(
              width: 280,
              child: Text(
                "Mark whether this is a required attribute.",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  color: AlpineColors.background1a,
                ),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 30),
    ];
  }

  List<Widget> _buildArray() {
    return [
      Row(
        children: [
          AlpineSwitch(
            initiallyOn: field.isList,
            onChange: (value) => field = SchemaField.copyWith(field, isList: value),
            disabled: true,
          ),
          const SizedBox(width: 15),
          Text("Array", style: TextStyle(color: AlpineColors.textColor1, fontWeight: FontWeight.w200, fontSize: 16)),
          const SizedBox(width: 5),
          ToolTipTarget(
            showTooltipOnHover: true,
            child: Container(
              width: 15,
              height: 15,
              alignment: Alignment.topCenter,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), color: AlpineColors.buttonColor2),
              child: Text("i",
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: "info",
                    color: AlpineColors.background1a,
                  )),
            ),
            toolTip: SizedBox(
              width: 280,
              child: Text(
                "Mark whether this attribute should act as an array.",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  color: AlpineColors.background1a,
                ),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 30),
    ];
  }

  List<Widget> _buildDefaultValue() {
    if (field.types.first is SchemaBoolean) {
      return [
        Row(
          children: [
            AlpineSwitch(
              initiallyOn: (field.types.first as SchemaBoolean).defaultValue ?? false,
              disabled: (field.types.first as SchemaBoolean).defaultValue == null,
              onChange: (value) => (field.types.first as SchemaBoolean).defaultValue = value,
            ),
            const SizedBox(width: 15),
            Text(
              "Default Value",
              style: TextStyle(
                color: AlpineColors.textColor1,
                fontSize: 16,
                fontWeight: FontWeight.w200,
              ),
            ),
            const SizedBox(width: 5),
            ToolTipTarget(
              showTooltipOnHover: true,
              child: Container(
                width: 15,
                height: 15,
                alignment: Alignment.topCenter,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: AlpineColors.buttonColor2,
                ),
                child: Text("i",
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: "info",
                      color: AlpineColors.background1a,
                    )),
              ),
              toolTip: SizedBox(
                width: 280,
                child: Text(
                  "Whether this attribute is set to true or false on creation.",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    color: AlpineColors.background1a,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 15),
            AlpineCheckbox(
              value: (field.types.first as SchemaDefaultValue).defaultValue == null,
              onChanged: (value) {
                (field.types.first as SchemaDefaultValue).defaultValueByDynamic = value != null && value ? null : false;
                setState(() {});
              },
            ),
            const SizedBox(width: 5),
            Text(
              "No value",
              style: TextStyle(
                color: AlpineColors.textColor1,
                fontSize: 14,
                fontWeight: FontWeight.w200,
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
      ];
    }

    return [
      Row(
        children: [
          Text(
            "Default Value",
            style: TextStyle(
              color: AlpineColors.textColor1,
              fontSize: 16,
              fontWeight: FontWeight.w200,
            ),
          ),
          const SizedBox(width: 15),
          AlpineCheckbox(
            value: (field.types.first as SchemaDefaultValue).defaultValue == null,
            onChanged: (value) {
              var emptyVal;
              if (field.types.first is SchemaInt) {
                emptyVal = 0;
              } else if (field.types.first is SchemaFloat) {
                emptyVal = 0.0;
              } else if (field.types.first is SchemaString) {
                emptyVal = "";
              } else if (field.types.first is SchemaEnum) {
                if ((field.types.first as SchemaEnum).elements.isNotEmpty) {
                  emptyVal = (field.types.first as SchemaEnum).elements.first;
                } else {
                  emptyVal = null;
                }
              } else {
                emptyVal = DateTime.now();
              }
              (field.types.first as SchemaDefaultValue).defaultValueByDynamic =
                  value != null && value ? null : emptyVal;
              setState(() {});
            },
          ),
          const SizedBox(width: 5),
          Text(
            "No value",
            style: TextStyle(
              color: AlpineColors.textColor1,
              fontSize: 14,
              fontWeight: FontWeight.w200,
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      if (field.types.first is SchemaInt)
        IntField(
          controller: _defaultValueController,
          disabled: (field.types.first as SchemaDefaultValue).defaultValue == null,
          onChanged: _onDefaultValueChanged,
        ),
      if (field.types.first is SchemaString)
        StringField(
          controller: _defaultValueController,
          disabled: (field.types.first as SchemaDefaultValue).defaultValue == null,
          onChanged: _onDefaultValueChanged,
        ),
      if (field.types.first is SchemaFloat)
        FloatField(
          controller: _defaultValueController,
          disabled: (field.types.first as SchemaDefaultValue).defaultValue == null,
          onChanged: _onDefaultValueChanged,
        ),
      if (field.types.first is SchemaEnum && (field.types.first as SchemaEnum).elements.isNotEmpty)
        EnumDefaultValueWidget(
          type: field.types.first as SchemaEnum,
        ),
      if (field.types.first is SchemaDate &&
          (field.types.first as SchemaDate).type == DateType.year &&
          (field.types.first as SchemaDefaultValue).defaultValue != null)
        SizedBox(
          width: double.infinity,
          height: 300,
          child: YearPicker(
              firstDate: DateTime(0),
              lastDate: DateTime(3000),
              selectedDate: (field.types.first as SchemaDefaultValue).defaultValue ?? DateTime.now(),
              onChanged: (value) =>
                  setState(() => (field.types.first as SchemaDefaultValue).defaultValueByDynamic = value)),
        ),
      if (field.types.first is SchemaDate &&
          (field.types.first as SchemaDate).type != DateType.year &&
          (field.types.first as SchemaDefaultValue).defaultValue != null)
        DateTimePicker(
          onChanged: (value) {
            try {
              (field.types.first as SchemaDefaultValue).defaultValueByDynamic = DateTime.parse(value);
            } catch (e) {
              print(e);
            }
          },
          initialValue: [DateType.time].contains((field.types.first as SchemaDate).type)
              ? DateFormat.Hms().format(((field.types.first as SchemaDefaultValue).defaultValue as DateTime))
              : null,
          initialTime:
              [DateType.datetime, DateType.date, DateType.timestamp].contains((field.types.first as SchemaDate).type)
                  ? TimeOfDay.now()
                  : null,
          initialDate:
              [DateType.datetime, DateType.date, DateType.timestamp].contains((field.types.first as SchemaDate).type)
                  ? DateTime.now()
                  : null,
          firstDate:
              [DateType.datetime, DateType.date, DateType.timestamp].contains((field.types.first as SchemaDate).type)
                  ? DateTime(0)
                  : null,
          lastDate:
              [DateType.datetime, DateType.date, DateType.timestamp].contains((field.types.first as SchemaDate).type)
                  ? DateTime(3000)
                  : null,
          type: _getDateTimePickerType(),
          style: false
              ? TextStyle(color: AlpineColors.textFieldColor1.withOpacity(0.3))
              : const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            hintText: "",
            hintStyle: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w200),
            // border: Border.all(color: Colors.black38, width: 1),
            // color: AlpineColors.background4a,
            fillColor: false ? AlpineColors.background4a : AlpineColors.textColor1,
            filled: true,
            focusColor: false ? Colors.transparent : AlpineColors.textColor1,
            hoverColor: false ? Colors.transparent : AlpineColors.textColor1,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ),
      const SizedBox(height: 30),
    ];
  }

  DateTimePickerType _getDateTimePickerType() {
    print((field.types.first as SchemaDate).type);
    switch ((field.types.first as SchemaDate).type) {
      case DateType.date:
        return DateTimePickerType.date;
      case DateType.datetime:
      case DateType.timestamp:
        return DateTimePickerType.dateTimeSeparate;
      case DateType.time:
        return DateTimePickerType.time;
      default:
        return DateTimePickerType.dateTimeSeparate;
    }
  }

  void _onDefaultValueChanged(String value) {
    if (field.types.isNotEmpty && field.types.first is SchemaDefaultValue) {
      (field.types.first as SchemaDefaultValue).defaultValueByDynamic = value;
    }
  }

  List<Widget> _buildElements() {
    List<Widget> elRow = [];
    var elements = (field.types.first as SchemaEnum).elements;
    for (int i = 0; i < elements.length; i++) {
      elRow.add(ElementRow(
        onChange: (value) {
          setState(() => elements[i] = value);
          // print((field.types.first as SchemaEnum).elements);
        },
        onRemove: (() => setState(() {
              (field.types.first as SchemaEnum).elements.removeAt(i);
            })),
      ));
    }

    return [
      Text(
        "Elements",
        style: TextStyle(
          color: AlpineColors.textColor1,
          fontSize: 16,
          fontWeight: FontWeight.w200,
        ),
      ),
      const SizedBox(height: 5),
      ...elRow,
      const SizedBox(height: 10),
      Row(
        children: [
          AlpineButton(
            label: "Add Element",
            color: AlpineColors.buttonColor2,
            isFilled: false,
            onTap: () => setState(() => (field.types.first as SchemaEnum).elements.add("")),
          ),
          const Expanded(child: SizedBox()),
        ],
      ),
      const SizedBox(height: 30),
    ];
  }

  List<Widget> _buildSize() {
    return [
      Row(
        children: [
          Text("Size",
              style: TextStyle(
                color: AlpineColors.textColor1,
                fontWeight: FontWeight.w200,
                fontSize: 16,
              )),
          const SizedBox(width: 15),
          AlpineCheckbox(
            key: const Key("addFieldRangeMax"),
            value: (field.types.first as SchemaSizeInt).size == null,
            onChanged: (value) {
              (field.types.first as SchemaSizeInt).size = value != null && value ? null : 0;
              setState(() {});
            },
          ),
          const SizedBox(width: 5),
          Text(
            "No value",
            style: TextStyle(
              color: AlpineColors.textColor1,
              fontSize: 14,
              fontWeight: FontWeight.w200,
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      IntField(
        controller: _sizeController,
        disabled: (field.types.first as SchemaSizeInt).size == null,
        onChanged: (value) {
          if (field.types.first is SchemaSizeInt) {
            (field.types.first as SchemaSizeInt).size = int.parse(value);
            setState(() {});
          }
        },
      ),
      const SizedBox(height: 10),
      SelectableText(
        "Size must be between 1 and 1,073,741,824",
        style: TextStyle(
          color: AlpineColors.textColor1,
          fontSize: 10,
          fontWeight: FontWeight.w200,
          height: 1.5,
        ),
      ),
      const SizedBox(height: 20),
    ];
  }

  List<Widget> _buildAttributeLabel() {
    return [
      Text(
        "Field ID",
        style: TextStyle(
          color: AlpineColors.textColor1,
          fontSize: 16,
          fontWeight: FontWeight.w200,
        ),
      ),
      const SizedBox(height: 15),
      StringField(
        controller: _fieldIdController,
        onChanged: (value) => field = SchemaField.copyWith(field, title: value),
      ),
      const SizedBox(height: 10),
      SelectableText(
        "Allowed Characters A-Z, a-z, 0-9, and non-leading underscore",
        style: TextStyle(
          color: AlpineColors.textColor1,
          fontSize: 10,
          fontWeight: FontWeight.w200,
          height: 1.5,
        ),
      ),
    ];
  }

  String _getHeadLabel() {
    if (field.types.first is SchemaTyped) {
      switch ((field.types.first as SchemaTyped).type) {
        case StringType.email:
          return "Add Email Attribute";
        case StringType.ip:
          return "Add IP Attribute";
        case StringType.longText:
          return "Add String Attribute";
        case StringType.mediumText:
          return "Add String Attribute";
        case StringType.text:
          return "Add String Attribute";
        case StringType.tinyText:
          return "Add String Attribute";
        case StringType.url:
          return "Add URL Attribute";
        case IntType.bigInt:
          return "Add Integer Attribute";
        case IntType.int:
          return "Add Integer Attribute";
        case IntType.mediumInt:
          return "Add Integer Attribute";
        case IntType.smallInt:
          return "Add Integer Attribute";
        case IntType.tinyInt:
          return "Add Integer Attribute";
        case FloatType.decimal:
          return "Add Float Attribute";
        case FloatType.double:
          return "Add Float Attribute";
        case FloatType.float:
          return "Add Float Attribute";
        default:
          return "Add Typed Attribute";
      }
    } else if (field.types.first is SchemaBoolean) {
      return "Add Boolean Attribute";
    } else if (field.types.first is SchemaEnum) {
      return "Add Enum Attribute";
    }

    return "no header...";
  }
}

class ElementRow extends StatefulWidget {
  const ElementRow({
    Key? key,
    this.onChange,
    this.onRemove,
  }) : super(key: key);

  final void Function(String)? onChange;
  final void Function()? onRemove;

  @override
  State<ElementRow> createState() => _ElementRowState();
}

class _ElementRowState extends State<ElementRow> {
  late TextEditingController controller;

  @override
  void initState() {
    controller = TextEditingController();
    controller.addListener(() {
      if (widget.onChange != null) {
        widget.onChange!(controller.text);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: StringField(
              controller: controller,
            ),
            // AlpineSelectionWidget(
            //   initalIndex: 0,
            //   options: ["title", "subtitle", "author", "publication_date"],
            // ),
          ),
          const SizedBox(width: 20),
          AlpineCloseButton(
            onTap: widget.onRemove,
          ),
        ],
      ),
    );
  }
}

class EnumElement {
  EnumElement({
    required this.index,
    required this.label,
  });

  final int index;
  String label;

  @override
  bool operator ==(Object other) => other is EnumElement && other.index == index;

  @override
  int get hashCode => Object.hash(index, label);
}

class EnumDefaultValueWidget extends StatelessWidget {
  const EnumDefaultValueWidget({
    Key? key,
    required this.type,
  }) : super(key: key);

  final SchemaEnum type;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: type.defaultValue != null ? AlpineColors.textColor1 : AlpineColors.background4a,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      // alignment: Alignment.center,
      child: DropdownButton<EnumElement>(
        iconEnabledColor: Colors.transparent,
        iconDisabledColor: Colors.transparent,
        focusColor: Colors.transparent,
        dropdownColor: AlpineColors.textColor1,
        value: _getEnumElementValue(),
        underline: const SizedBox(),
        icon: const SizedBox(),
        hint: Text(
          "None Selected",
          style: TextStyle(color: AlpineColors.warningColor),
        ),
        items: _buildElementMenuItems(),
        onChanged: type.defaultValue == null
            ? null
            : (EnumElement? value) {
                if (type is SchemaDefaultValue && value != null) {
                  type.defaultValueByDynamic = value.label;
                  // setState(() {});
                }
              },
      ),
    );
  }

  EnumElement _getEnumElementValue() {
    // get current default value element
    // otherwise return first element
    var elements = type.elements;
    var defaultValue = type.defaultValue;
    if (defaultValue == null) {
      return EnumElement(
        index: 0,
        label: type.elements.first,
      );
    }
    int defaultValueIndex = 0;
    for (int i = 0; i < elements.length; i++) {
      if (elements[i] == defaultValue) defaultValueIndex = i;
    }
    return EnumElement(index: defaultValueIndex, label: defaultValue);
  }

  List<DropdownMenuItem<EnumElement>> _buildElementMenuItems() {
    print("_buildElementMenuItems() called");
    var elements = type.elements;
    List<DropdownMenuItem<EnumElement>> items = [];
    for (int i = 0; i < elements.length; i++) {
      items.add(DropdownMenuItem<EnumElement>(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(elements[i],
                  style: TextStyle(
                      color: type.defaultValue != null
                          ? AlpineColors.background1a
                          : AlpineColors.textColor2.withOpacity(0.2)))
            ],
          ),
          value: EnumElement(index: i, label: elements[i])));
    }
    return items;
  }
}
