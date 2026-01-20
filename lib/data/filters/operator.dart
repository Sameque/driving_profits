enum Operator {
  equal('eq'),
  lessThanOrEqual('lte'),
  greaterThanOrEqual('gte');

  final String value;
  const Operator(this.value);
}
