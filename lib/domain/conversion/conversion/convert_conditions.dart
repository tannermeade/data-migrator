class ConvertConditional {
  ConvertConditional({
    required this.conditions,
    this.conditionOperand = ConditionOperand.and,
  });

  List<SingleConvertCondition> conditions;
  ConditionOperand conditionOperand;

  bool execute(List sourceMapValues) {
    bool? result;
    for (var condition in conditions) {
      if (result == null) {
        result = condition.execute(sourceMapValues);
      } else if (conditionOperand == ConditionOperand.and) {
        result = condition.execute(sourceMapValues) && result;
      } else {
        result = condition.execute(sourceMapValues) || result;
      }
    }
    return result!;
  }
}

class SingleConvertCondition {
  SingleConvertCondition({
    required this.operator,
    required this.preOperandField,
    required this.postOperand,
  });

  ConnectionConditonOperator operator;
  List<int> preOperandField;
  dynamic postOperand;

  bool execute(List sourceMapValues) {
    switch (operator) {
      case ConnectionConditonOperator.equals:
        return sourceMapValues[preOperandField.last] == postOperand;
      case ConnectionConditonOperator.notEqual:
        return sourceMapValues[preOperandField.last] != postOperand;
      case ConnectionConditonOperator.isNull:
        return sourceMapValues[preOperandField.last] == null;
      case ConnectionConditonOperator.isNotNull:
        return sourceMapValues[preOperandField.last] != null;
      // case ConnectionConditonOperator.greaterThan:
      //   return preOperandField > postOperand;
      // case ConnectionConditonOperator.greaterThanOrEqualTo:
      //   return preOperandField >= postOperand;
      // case ConnectionConditonOperator.lessThan:
      //   return preOperandField < postOperand;
      // case ConnectionConditonOperator.lessThanOrEqualTo:
      //   return preOperandField <= postOperand;
      // case ConnectionConditonOperator.typeIs:
      //   return preOperandField is postOperand.runtimeType;
      // case ConnectionConditonOperator.typeIsNot:
      //   return preOperandField !is postOperand.runtimeType;
    }
  }
}

enum ConnectionConditonOperator {
  equals,
  notEqual,
  isNull,
  isNotNull,
  // greaterThan,
  // greaterThanOrEqualTo,
  // lessThan,
  // lessThanOrEqualTo,
  // typeIs,
  // typeIsNot,
}

enum ConditionOperand {
  and,
  or,
}