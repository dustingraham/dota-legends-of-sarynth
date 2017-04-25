function RandomInt(min, max) {
  min = Math.ceil(min);
  max = Math.floor(max);
  return Math.floor(Math.random() * (max - min)) + min;
}

function RemapVal(v, a, b, c, d)
{
    if (a === b) return c;
    return c + (d - c) * (v - a) / (b - a);
}
