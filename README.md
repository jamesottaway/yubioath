# YubiOATH

A mostly-complete Ruby implementation of the [YubiOATH applet protocol](https://developers.yubico.com/ykneo-oath/Protocol.html).

## Usage

The `YubiOATH` class accepts a `card`, which must respond to `#transmit(apdu)`. See [costan/smartcard](https://github.com/costan/smartcard) for more info.

``` ruby
yubioath = YubiOATH.new(card)

yubioath.put(name: 'foo', secret: '123456')            # => true
yubioath.calculate(name: 'foo', timestamp: Time.now)   # => '237846'

yubioath.put(name: 'bar', secret: '345678')   # => true
yubioath.put(name: 'qux', secret: '567890')   # => true
yubioath.list.keys                            # => ['foo', 'bar', 'qux']
yubioath.calculate_all(timestamp: Time.now)   # => {'foo' => '234526', 'bar' => '293857', 'qux' => '934856'}

yubioath.delete('qux')   # => true
yubioath.list.keys   # => ['foo', 'bar']

yubioath.reset        # => true
yubioath.list.empty?  # => true
```

### Instructions

You can also trigger the instructions by instantiating the relevant class with a `card` and invoking its `#call` method.

``` ruby
calculate = YubiOATH::Calculate.new(card)
calculate_all = YubiOATH::CalculateAll.new(card)
delete = YubiOATH::Delete.new(card)
list = YubiOATH::List.new(card)
put = YubiOATH::Put.new(card)
reset = YubiOATH::Reset.new(card)

put.call(name: 'foo', secret: '123456')            # => true
calculate.call(name: 'foo', timestamp: Time.now)   # => '237846'

put.call(name: 'bar', secret: '345678')   # => true
put.call(name: 'qux', secret: '567890')   # => true
list.call.keys                            # => ['foo', 'bar', 'qux']
calculate_all.call(timestamp: Time.now)   # => {'foo' => '234526', 'bar' => '293857', 'qux' => '934856'}

delete.call('qux')   # => true
list.call.keys   # => ['foo', 'bar']

reset.call        # => true
list.call.empty?  # => true
```
