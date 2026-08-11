## V-SM3 

v-sm3 is a SM3 hash function for vlang.


### Env

 - vlang >= 0.5.2


### Adding v-sm3 as a dependency

Add the dependency to your project:

```bash
v install deatil.sm3
```

or 

```bash
v install --git https://github.com/deatil/v-sm3
```

The `v-sm3` structure can be imported in your application with:

```v
import deatil.sm3
```


### Get Starting

~~~v
import deatil.sm3

fn main() {
    mut d := sm3.new()
    d.write("abc".bytes()) or { panic(err) }
    out := d.sum([])
    
    // output: 66c7f0f462eeedd9d1f2d46bdc10e4e24167c4875cf2f7a2297da02b8f4ba8e0
    println("output: ${out.hex()}")
}
~~~


### LICENSE

*  The library LICENSE is `Apache2`, using the library need keep the LICENSE.


### Copyright

*  Copyright deatil(https://github.com/deatil).
