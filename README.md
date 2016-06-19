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

### Calculate

Do calculate for one named code.

``` ruby
yubioath.calculate(name: 'foo', timestamp: Time.now)   # => '237893'
```

### Calculate All

Do calculation for all available codes.

``` ruby
yubioath.calculate_all(timestamp: Time.now)   # => { 'foo' => '576238', 'bar' => '123895' }
```

### Delete

Deletes an existing code.

``` ruby
yubioath.delete(name: 'foo')   # => true
```

### List

List configured codes.

``` ruby
yubioath.list   # => { 'foo' => { type: :totp, algorithm: :sha256 } }
```

### Put

Adds a new (or overwrites) OATH code.

``` ruby
yubioath.put(name: 'foo', secret: 'bar', …)   # => true
```

### Reset

Reset the applet to just-installed state.

``` ruby
yubioath.reset   # => true
```
