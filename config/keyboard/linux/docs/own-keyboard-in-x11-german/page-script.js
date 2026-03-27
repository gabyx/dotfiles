/******/ ;(() => {
  // webpackBootstrap
  /******/ var __webpack_modules__ = {
    /***/ 3737: /***/ (
      module,
      __unused_webpack_exports,
      __webpack_require__,
    ) => {
      "use strict"

      var GetIntrinsic = __webpack_require__(55050)
      var callBind = __webpack_require__(68375)
      var $indexOf = callBind(GetIntrinsic("String.prototype.indexOf"))
      module.exports = function callBoundIntrinsic(name, allowMissing) {
        var intrinsic = GetIntrinsic(name, !!allowMissing)
        if (
          typeof intrinsic === "function" &&
          $indexOf(name, ".prototype.") > -1
        ) {
          return callBind(intrinsic)
        }
        return intrinsic
      }

      /***/
    },

    /***/ 68375: /***/ (
      module,
      __unused_webpack_exports,
      __webpack_require__,
    ) => {
      "use strict"

      var bind = __webpack_require__(36046)
      var GetIntrinsic = __webpack_require__(55050)
      var $apply = GetIntrinsic("%Function.prototype.apply%")
      var $call = GetIntrinsic("%Function.prototype.call%")
      var $reflectApply =
        GetIntrinsic("%Reflect.apply%", true) || bind.call($call, $apply)
      var $gOPD = GetIntrinsic("%Object.getOwnPropertyDescriptor%", true)
      var $defineProperty = GetIntrinsic("%Object.defineProperty%", true)
      var $max = GetIntrinsic("%Math.max%")
      if ($defineProperty) {
        try {
          $defineProperty({}, "a", {
            value: 1,
          })
        } catch (e) {
          // IE 8 has a broken defineProperty
          $defineProperty = null
        }
      }
      module.exports = function callBind(originalFunction) {
        var func = $reflectApply(bind, $call, arguments)
        if ($gOPD && $defineProperty) {
          var desc = $gOPD(func, "length")
          if (desc.configurable) {
            // original length, plus the receiver, minus any additional arguments (after the receiver)
            $defineProperty(func, "length", {
              value:
                1 + $max(0, originalFunction.length - (arguments.length - 1)),
            })
          }
        }
        return func
      }
      var applyBind = function applyBind() {
        return $reflectApply(bind, $apply, arguments)
      }
      if ($defineProperty) {
        $defineProperty(module.exports, "apply", {
          value: applyBind,
        })
      } else {
        module.exports.apply = applyBind
      }

      /***/
    },

    /***/ 51820: /***/ (module) => {
      "use strict"

      /* eslint no-invalid-this: 1 */
      var ERROR_MESSAGE = "Function.prototype.bind called on incompatible "
      var slice = Array.prototype.slice
      var toStr = Object.prototype.toString
      var funcType = "[object Function]"
      module.exports = function bind(that) {
        var target = this
        if (typeof target !== "function" || toStr.call(target) !== funcType) {
          throw new TypeError(ERROR_MESSAGE + target)
        }
        var args = slice.call(arguments, 1)
        var bound
        var binder = function () {
          if (this instanceof bound) {
            var result = target.apply(this, args.concat(slice.call(arguments)))
            if (Object(result) === result) {
              return result
            }
            return this
          } else {
            return target.apply(that, args.concat(slice.call(arguments)))
          }
        }
        var boundLength = Math.max(0, target.length - args.length)
        var boundArgs = []
        for (var i = 0; i < boundLength; i++) {
          boundArgs.push("$" + i)
        }
        bound = Function(
          "binder",
          "return function (" +
            boundArgs.join(",") +
            "){ return binder.apply(this,arguments); }",
        )(binder)
        if (target.prototype) {
          var Empty = function Empty() {}
          Empty.prototype = target.prototype
          bound.prototype = new Empty()
          Empty.prototype = null
        }
        return bound
      }

      /***/
    },

    /***/ 36046: /***/ (
      module,
      __unused_webpack_exports,
      __webpack_require__,
    ) => {
      "use strict"

      var implementation = __webpack_require__(51820)
      module.exports = Function.prototype.bind || implementation

      /***/
    },

    /***/ 55050: /***/ (
      module,
      __unused_webpack_exports,
      __webpack_require__,
    ) => {
      "use strict"

      var undefined
      var $SyntaxError = SyntaxError
      var $Function = Function
      var $TypeError = TypeError

      // eslint-disable-next-line consistent-return
      var getEvalledConstructor = function (expressionSyntax) {
        try {
          return $Function(
            '"use strict"; return (' + expressionSyntax + ").constructor;",
          )()
        } catch (e) {}
      }
      var $gOPD = Object.getOwnPropertyDescriptor
      if ($gOPD) {
        try {
          $gOPD({}, "")
        } catch (e) {
          $gOPD = null // this is IE 8, which has a broken gOPD
        }
      }

      var throwTypeError = function () {
        throw new $TypeError()
      }
      var ThrowTypeError = $gOPD
        ? (function () {
            try {
              // eslint-disable-next-line no-unused-expressions, no-caller, no-restricted-properties
              arguments.callee // IE 8 does not throw here
              return throwTypeError
            } catch (calleeThrows) {
              try {
                // IE 8 throws on Object.getOwnPropertyDescriptor(arguments, '')
                return $gOPD(arguments, "callee").get
              } catch (gOPDthrows) {
                return throwTypeError
              }
            }
          })()
        : throwTypeError
      var hasSymbols = __webpack_require__(8269)()
      var hasProto = __webpack_require__(1886)()
      var getProto =
        Object.getPrototypeOf ||
        (hasProto
          ? function (x) {
              return x.__proto__
            } // eslint-disable-line no-proto
          : null)
      var needsEval = {}
      var TypedArray =
        typeof Uint8Array === "undefined" || !getProto
          ? undefined
          : getProto(Uint8Array)
      var INTRINSICS = {
        "%AggregateError%":
          typeof AggregateError === "undefined" ? undefined : AggregateError,
        "%Array%": Array,
        "%ArrayBuffer%":
          typeof ArrayBuffer === "undefined" ? undefined : ArrayBuffer,
        "%ArrayIteratorPrototype%":
          hasSymbols && getProto ? getProto([][Symbol.iterator]()) : undefined,
        "%AsyncFromSyncIteratorPrototype%": undefined,
        "%AsyncFunction%": needsEval,
        "%AsyncGenerator%": needsEval,
        "%AsyncGeneratorFunction%": needsEval,
        "%AsyncIteratorPrototype%": needsEval,
        "%Atomics%": typeof Atomics === "undefined" ? undefined : Atomics,
        "%BigInt%": typeof BigInt === "undefined" ? undefined : BigInt,
        "%BigInt64Array%":
          typeof BigInt64Array === "undefined" ? undefined : BigInt64Array,
        "%BigUint64Array%":
          typeof BigUint64Array === "undefined" ? undefined : BigUint64Array,
        "%Boolean%": Boolean,
        "%DataView%": typeof DataView === "undefined" ? undefined : DataView,
        "%Date%": Date,
        "%decodeURI%": decodeURI,
        "%decodeURIComponent%": decodeURIComponent,
        "%encodeURI%": encodeURI,
        "%encodeURIComponent%": encodeURIComponent,
        "%Error%": Error,
        "%eval%": eval,
        // eslint-disable-line no-eval
        "%EvalError%": EvalError,
        "%Float32Array%":
          typeof Float32Array === "undefined" ? undefined : Float32Array,
        "%Float64Array%":
          typeof Float64Array === "undefined" ? undefined : Float64Array,
        "%FinalizationRegistry%":
          typeof FinalizationRegistry === "undefined"
            ? undefined
            : FinalizationRegistry,
        "%Function%": $Function,
        "%GeneratorFunction%": needsEval,
        "%Int8Array%": typeof Int8Array === "undefined" ? undefined : Int8Array,
        "%Int16Array%":
          typeof Int16Array === "undefined" ? undefined : Int16Array,
        "%Int32Array%":
          typeof Int32Array === "undefined" ? undefined : Int32Array,
        "%isFinite%": isFinite,
        "%isNaN%": isNaN,
        "%IteratorPrototype%":
          hasSymbols && getProto
            ? getProto(getProto([][Symbol.iterator]()))
            : undefined,
        "%JSON%": typeof JSON === "object" ? JSON : undefined,
        "%Map%": typeof Map === "undefined" ? undefined : Map,
        "%MapIteratorPrototype%":
          typeof Map === "undefined" || !hasSymbols || !getProto
            ? undefined
            : getProto(new Map()[Symbol.iterator]()),
        "%Math%": Math,
        "%Number%": Number,
        "%Object%": Object,
        "%parseFloat%": parseFloat,
        "%parseInt%": parseInt,
        "%Promise%": typeof Promise === "undefined" ? undefined : Promise,
        "%Proxy%": typeof Proxy === "undefined" ? undefined : Proxy,
        "%RangeError%": RangeError,
        "%ReferenceError%": ReferenceError,
        "%Reflect%": typeof Reflect === "undefined" ? undefined : Reflect,
        "%RegExp%": RegExp,
        "%Set%": typeof Set === "undefined" ? undefined : Set,
        "%SetIteratorPrototype%":
          typeof Set === "undefined" || !hasSymbols || !getProto
            ? undefined
            : getProto(new Set()[Symbol.iterator]()),
        "%SharedArrayBuffer%":
          typeof SharedArrayBuffer === "undefined"
            ? undefined
            : SharedArrayBuffer,
        "%String%": String,
        "%StringIteratorPrototype%":
          hasSymbols && getProto ? getProto(""[Symbol.iterator]()) : undefined,
        "%Symbol%": hasSymbols ? Symbol : undefined,
        "%SyntaxError%": $SyntaxError,
        "%ThrowTypeError%": ThrowTypeError,
        "%TypedArray%": TypedArray,
        "%TypeError%": $TypeError,
        "%Uint8Array%":
          typeof Uint8Array === "undefined" ? undefined : Uint8Array,
        "%Uint8ClampedArray%":
          typeof Uint8ClampedArray === "undefined"
            ? undefined
            : Uint8ClampedArray,
        "%Uint16Array%":
          typeof Uint16Array === "undefined" ? undefined : Uint16Array,
        "%Uint32Array%":
          typeof Uint32Array === "undefined" ? undefined : Uint32Array,
        "%URIError%": URIError,
        "%WeakMap%": typeof WeakMap === "undefined" ? undefined : WeakMap,
        "%WeakRef%": typeof WeakRef === "undefined" ? undefined : WeakRef,
        "%WeakSet%": typeof WeakSet === "undefined" ? undefined : WeakSet,
      }
      if (getProto) {
        try {
          null.error // eslint-disable-line no-unused-expressions
        } catch (e) {
          // https://github.com/tc39/proposal-shadowrealm/pull/384#issuecomment-1364264229
          var errorProto = getProto(getProto(e))
          INTRINSICS["%Error.prototype%"] = errorProto
        }
      }
      var doEval = function doEval(name) {
        var value
        if (name === "%AsyncFunction%") {
          value = getEvalledConstructor("async function () {}")
        } else if (name === "%GeneratorFunction%") {
          value = getEvalledConstructor("function* () {}")
        } else if (name === "%AsyncGeneratorFunction%") {
          value = getEvalledConstructor("async function* () {}")
        } else if (name === "%AsyncGenerator%") {
          var fn = doEval("%AsyncGeneratorFunction%")
          if (fn) {
            value = fn.prototype
          }
        } else if (name === "%AsyncIteratorPrototype%") {
          var gen = doEval("%AsyncGenerator%")
          if (gen && getProto) {
            value = getProto(gen.prototype)
          }
        }
        INTRINSICS[name] = value
        return value
      }
      var LEGACY_ALIASES = {
        "%ArrayBufferPrototype%": ["ArrayBuffer", "prototype"],
        "%ArrayPrototype%": ["Array", "prototype"],
        "%ArrayProto_entries%": ["Array", "prototype", "entries"],
        "%ArrayProto_forEach%": ["Array", "prototype", "forEach"],
        "%ArrayProto_keys%": ["Array", "prototype", "keys"],
        "%ArrayProto_values%": ["Array", "prototype", "values"],
        "%AsyncFunctionPrototype%": ["AsyncFunction", "prototype"],
        "%AsyncGenerator%": ["AsyncGeneratorFunction", "prototype"],
        "%AsyncGeneratorPrototype%": [
          "AsyncGeneratorFunction",
          "prototype",
          "prototype",
        ],
        "%BooleanPrototype%": ["Boolean", "prototype"],
        "%DataViewPrototype%": ["DataView", "prototype"],
        "%DatePrototype%": ["Date", "prototype"],
        "%ErrorPrototype%": ["Error", "prototype"],
        "%EvalErrorPrototype%": ["EvalError", "prototype"],
        "%Float32ArrayPrototype%": ["Float32Array", "prototype"],
        "%Float64ArrayPrototype%": ["Float64Array", "prototype"],
        "%FunctionPrototype%": ["Function", "prototype"],
        "%Generator%": ["GeneratorFunction", "prototype"],
        "%GeneratorPrototype%": ["GeneratorFunction", "prototype", "prototype"],
        "%Int8ArrayPrototype%": ["Int8Array", "prototype"],
        "%Int16ArrayPrototype%": ["Int16Array", "prototype"],
        "%Int32ArrayPrototype%": ["Int32Array", "prototype"],
        "%JSONParse%": ["JSON", "parse"],
        "%JSONStringify%": ["JSON", "stringify"],
        "%MapPrototype%": ["Map", "prototype"],
        "%NumberPrototype%": ["Number", "prototype"],
        "%ObjectPrototype%": ["Object", "prototype"],
        "%ObjProto_toString%": ["Object", "prototype", "toString"],
        "%ObjProto_valueOf%": ["Object", "prototype", "valueOf"],
        "%PromisePrototype%": ["Promise", "prototype"],
        "%PromiseProto_then%": ["Promise", "prototype", "then"],
        "%Promise_all%": ["Promise", "all"],
        "%Promise_reject%": ["Promise", "reject"],
        "%Promise_resolve%": ["Promise", "resolve"],
        "%RangeErrorPrototype%": ["RangeError", "prototype"],
        "%ReferenceErrorPrototype%": ["ReferenceError", "prototype"],
        "%RegExpPrototype%": ["RegExp", "prototype"],
        "%SetPrototype%": ["Set", "prototype"],
        "%SharedArrayBufferPrototype%": ["SharedArrayBuffer", "prototype"],
        "%StringPrototype%": ["String", "prototype"],
        "%SymbolPrototype%": ["Symbol", "prototype"],
        "%SyntaxErrorPrototype%": ["SyntaxError", "prototype"],
        "%TypedArrayPrototype%": ["TypedArray", "prototype"],
        "%TypeErrorPrototype%": ["TypeError", "prototype"],
        "%Uint8ArrayPrototype%": ["Uint8Array", "prototype"],
        "%Uint8ClampedArrayPrototype%": ["Uint8ClampedArray", "prototype"],
        "%Uint16ArrayPrototype%": ["Uint16Array", "prototype"],
        "%Uint32ArrayPrototype%": ["Uint32Array", "prototype"],
        "%URIErrorPrototype%": ["URIError", "prototype"],
        "%WeakMapPrototype%": ["WeakMap", "prototype"],
        "%WeakSetPrototype%": ["WeakSet", "prototype"],
      }
      var bind = __webpack_require__(36046)
      var hasOwn = __webpack_require__(50163)
      var $concat = bind.call(Function.call, Array.prototype.concat)
      var $spliceApply = bind.call(Function.apply, Array.prototype.splice)
      var $replace = bind.call(Function.call, String.prototype.replace)
      var $strSlice = bind.call(Function.call, String.prototype.slice)
      var $exec = bind.call(Function.call, RegExp.prototype.exec)

      /* adapted from https://github.com/lodash/lodash/blob/4.17.15/dist/lodash.js#L6735-L6744 */
      var rePropName =
        /[^%.[\]]+|\[(?:(-?\d+(?:\.\d+)?)|(["'])((?:(?!\2)[^\\]|\\.)*?)\2)\]|(?=(?:\.|\[\])(?:\.|\[\]|%$))/g
      var reEscapeChar =
        /\\(\\)?/g /** Used to match backslashes in property paths. */
      var stringToPath = function stringToPath(string) {
        var first = $strSlice(string, 0, 1)
        var last = $strSlice(string, -1)
        if (first === "%" && last !== "%") {
          throw new $SyntaxError(
            "invalid intrinsic syntax, expected closing `%`",
          )
        } else if (last === "%" && first !== "%") {
          throw new $SyntaxError(
            "invalid intrinsic syntax, expected opening `%`",
          )
        }
        var result = []
        $replace(
          string,
          rePropName,
          function (match, number, quote, subString) {
            result[result.length] = quote
              ? $replace(subString, reEscapeChar, "$1")
              : number || match
          },
        )
        return result
      }
      /* end adaptation */

      var getBaseIntrinsic = function getBaseIntrinsic(name, allowMissing) {
        var intrinsicName = name
        var alias
        if (hasOwn(LEGACY_ALIASES, intrinsicName)) {
          alias = LEGACY_ALIASES[intrinsicName]
          intrinsicName = "%" + alias[0] + "%"
        }
        if (hasOwn(INTRINSICS, intrinsicName)) {
          var value = INTRINSICS[intrinsicName]
          if (value === needsEval) {
            value = doEval(intrinsicName)
          }
          if (typeof value === "undefined" && !allowMissing) {
            throw new $TypeError(
              "intrinsic " +
                name +
                " exists, but is not available. Please file an issue!",
            )
          }
          return {
            alias: alias,
            name: intrinsicName,
            value: value,
          }
        }
        throw new $SyntaxError("intrinsic " + name + " does not exist!")
      }
      module.exports = function GetIntrinsic(name, allowMissing) {
        if (typeof name !== "string" || name.length === 0) {
          throw new $TypeError("intrinsic name must be a non-empty string")
        }
        if (arguments.length > 1 && typeof allowMissing !== "boolean") {
          throw new $TypeError('"allowMissing" argument must be a boolean')
        }
        if ($exec(/^%?[^%]*%?$/, name) === null) {
          throw new $SyntaxError(
            "`%` may not be present anywhere but at the beginning and end of the intrinsic name",
          )
        }
        var parts = stringToPath(name)
        var intrinsicBaseName = parts.length > 0 ? parts[0] : ""
        var intrinsic = getBaseIntrinsic(
          "%" + intrinsicBaseName + "%",
          allowMissing,
        )
        var intrinsicRealName = intrinsic.name
        var value = intrinsic.value
        var skipFurtherCaching = false
        var alias = intrinsic.alias
        if (alias) {
          intrinsicBaseName = alias[0]
          $spliceApply(parts, $concat([0, 1], alias))
        }
        for (var i = 1, isOwn = true; i < parts.length; i += 1) {
          var part = parts[i]
          var first = $strSlice(part, 0, 1)
          var last = $strSlice(part, -1)
          if (
            (first === '"' ||
              first === "'" ||
              first === "`" ||
              last === '"' ||
              last === "'" ||
              last === "`") &&
            first !== last
          ) {
            throw new $SyntaxError(
              "property names with quotes must have matching quotes",
            )
          }
          if (part === "constructor" || !isOwn) {
            skipFurtherCaching = true
          }
          intrinsicBaseName += "." + part
          intrinsicRealName = "%" + intrinsicBaseName + "%"
          if (hasOwn(INTRINSICS, intrinsicRealName)) {
            value = INTRINSICS[intrinsicRealName]
          } else if (value != null) {
            if (!(part in value)) {
              if (!allowMissing) {
                throw new $TypeError(
                  "base intrinsic for " +
                    name +
                    " exists, but the property is not available.",
                )
              }
              return void undefined
            }
            if ($gOPD && i + 1 >= parts.length) {
              var desc = $gOPD(value, part)
              isOwn = !!desc

              // By convention, when a data property is converted to an accessor
              // property to emulate a data property that does not suffer from
              // the override mistake, that accessor's getter is marked with
              // an `originalValue` property. Here, when we detect this, we
              // uphold the illusion by pretending to see that original data
              // property, i.e., returning the value rather than the getter
              // itself.
              if (isOwn && "get" in desc && !("originalValue" in desc.get)) {
                value = desc.get
              } else {
                value = value[part]
              }
            } else {
              isOwn = hasOwn(value, part)
              value = value[part]
            }
            if (isOwn && !skipFurtherCaching) {
              INTRINSICS[intrinsicRealName] = value
            }
          }
        }
        return value
      }

      /***/
    },

    /***/ 1886: /***/ (module) => {
      "use strict"

      var test = {
        foo: {},
      }
      var $Object = Object
      module.exports = function hasProto() {
        return (
          {
            __proto__: test,
          }.foo === test.foo &&
          !(
            {
              __proto__: null,
            } instanceof $Object
          )
        )
      }

      /***/
    },

    /***/ 8269: /***/ (
      module,
      __unused_webpack_exports,
      __webpack_require__,
    ) => {
      "use strict"

      var origSymbol = typeof Symbol !== "undefined" && Symbol
      var hasSymbolSham = __webpack_require__(88928)
      module.exports = function hasNativeSymbols() {
        if (typeof origSymbol !== "function") {
          return false
        }
        if (typeof Symbol !== "function") {
          return false
        }
        if (typeof origSymbol("foo") !== "symbol") {
          return false
        }
        if (typeof Symbol("bar") !== "symbol") {
          return false
        }
        return hasSymbolSham()
      }

      /***/
    },

    /***/ 88928: /***/ (module) => {
      "use strict"

      /* eslint complexity: [2, 18], max-statements: [2, 33] */
      module.exports = function hasSymbols() {
        if (
          typeof Symbol !== "function" ||
          typeof Object.getOwnPropertySymbols !== "function"
        ) {
          return false
        }
        if (typeof Symbol.iterator === "symbol") {
          return true
        }
        var obj = {}
        var sym = Symbol("test")
        var symObj = Object(sym)
        if (typeof sym === "string") {
          return false
        }
        if (Object.prototype.toString.call(sym) !== "[object Symbol]") {
          return false
        }
        if (Object.prototype.toString.call(symObj) !== "[object Symbol]") {
          return false
        }

        // temp disabled per https://github.com/ljharb/object.assign/issues/17
        // if (sym instanceof Symbol) { return false; }
        // temp disabled per https://github.com/WebReflection/get-own-property-symbols/issues/4
        // if (!(symObj instanceof Symbol)) { return false; }

        // if (typeof Symbol.prototype.toString !== 'function') { return false; }
        // if (String(sym) !== Symbol.prototype.toString.call(sym)) { return false; }

        var symVal = 42
        obj[sym] = symVal
        for (sym in obj) {
          return false
        } // eslint-disable-line no-restricted-syntax, no-unreachable-loop
        if (
          typeof Object.keys === "function" &&
          Object.keys(obj).length !== 0
        ) {
          return false
        }
        if (
          typeof Object.getOwnPropertyNames === "function" &&
          Object.getOwnPropertyNames(obj).length !== 0
        ) {
          return false
        }
        var syms = Object.getOwnPropertySymbols(obj)
        if (syms.length !== 1 || syms[0] !== sym) {
          return false
        }
        if (!Object.prototype.propertyIsEnumerable.call(obj, sym)) {
          return false
        }
        if (typeof Object.getOwnPropertyDescriptor === "function") {
          var descriptor = Object.getOwnPropertyDescriptor(obj, sym)
          if (descriptor.value !== symVal || descriptor.enumerable !== true) {
            return false
          }
        }
        return true
      }

      /***/
    },

    /***/ 50163: /***/ (
      module,
      __unused_webpack_exports,
      __webpack_require__,
    ) => {
      "use strict"

      var bind = __webpack_require__(36046)
      module.exports = bind.call(Function.call, Object.prototype.hasOwnProperty)

      /***/
    },

    /***/ 87676: /***/ (
      module,
      __unused_webpack_exports,
      __webpack_require__,
    ) => {
      var hasMap = typeof Map === "function" && Map.prototype
      var mapSizeDescriptor =
        Object.getOwnPropertyDescriptor && hasMap
          ? Object.getOwnPropertyDescriptor(Map.prototype, "size")
          : null
      var mapSize =
        hasMap &&
        mapSizeDescriptor &&
        typeof mapSizeDescriptor.get === "function"
          ? mapSizeDescriptor.get
          : null
      var mapForEach = hasMap && Map.prototype.forEach
      var hasSet = typeof Set === "function" && Set.prototype
      var setSizeDescriptor =
        Object.getOwnPropertyDescriptor && hasSet
          ? Object.getOwnPropertyDescriptor(Set.prototype, "size")
          : null
      var setSize =
        hasSet &&
        setSizeDescriptor &&
        typeof setSizeDescriptor.get === "function"
          ? setSizeDescriptor.get
          : null
      var setForEach = hasSet && Set.prototype.forEach
      var hasWeakMap = typeof WeakMap === "function" && WeakMap.prototype
      var weakMapHas = hasWeakMap ? WeakMap.prototype.has : null
      var hasWeakSet = typeof WeakSet === "function" && WeakSet.prototype
      var weakSetHas = hasWeakSet ? WeakSet.prototype.has : null
      var hasWeakRef = typeof WeakRef === "function" && WeakRef.prototype
      var weakRefDeref = hasWeakRef ? WeakRef.prototype.deref : null
      var booleanValueOf = Boolean.prototype.valueOf
      var objectToString = Object.prototype.toString
      var functionToString = Function.prototype.toString
      var $match = String.prototype.match
      var $slice = String.prototype.slice
      var $replace = String.prototype.replace
      var $toUpperCase = String.prototype.toUpperCase
      var $toLowerCase = String.prototype.toLowerCase
      var $test = RegExp.prototype.test
      var $concat = Array.prototype.concat
      var $join = Array.prototype.join
      var $arrSlice = Array.prototype.slice
      var $floor = Math.floor
      var bigIntValueOf =
        typeof BigInt === "function" ? BigInt.prototype.valueOf : null
      var gOPS = Object.getOwnPropertySymbols
      var symToString =
        typeof Symbol === "function" && typeof Symbol.iterator === "symbol"
          ? Symbol.prototype.toString
          : null
      var hasShammedSymbols =
        typeof Symbol === "function" && typeof Symbol.iterator === "object"
      // ie, `has-tostringtag/shams
      var toStringTag =
        typeof Symbol === "function" &&
        Symbol.toStringTag &&
        (typeof Symbol.toStringTag === hasShammedSymbols ? "object" : "symbol")
          ? Symbol.toStringTag
          : null
      var isEnumerable = Object.prototype.propertyIsEnumerable
      var gPO =
        (typeof Reflect === "function"
          ? Reflect.getPrototypeOf
          : Object.getPrototypeOf) ||
        ([].__proto__ === Array.prototype // eslint-disable-line no-proto
          ? function (O) {
              return O.__proto__ // eslint-disable-line no-proto
            }
          : null)
      function addNumericSeparator(num, str) {
        if (
          num === Infinity ||
          num === -Infinity ||
          num !== num ||
          (num && num > -1000 && num < 1000) ||
          $test.call(/e/, str)
        ) {
          return str
        }
        var sepRegex = /[0-9](?=(?:[0-9]{3})+(?![0-9]))/g
        if (typeof num === "number") {
          var int = num < 0 ? -$floor(-num) : $floor(num) // trunc(num)
          if (int !== num) {
            var intStr = String(int)
            var dec = $slice.call(str, intStr.length + 1)
            return (
              $replace.call(intStr, sepRegex, "$&_") +
              "." +
              $replace.call($replace.call(dec, /([0-9]{3})/g, "$&_"), /_$/, "")
            )
          }
        }
        return $replace.call(str, sepRegex, "$&_")
      }
      var utilInspect = __webpack_require__(53260)
      var inspectCustom = utilInspect.custom
      var inspectSymbol = isSymbol(inspectCustom) ? inspectCustom : null
      module.exports = function inspect_(obj, options, depth, seen) {
        var opts = options || {}
        if (
          has(opts, "quoteStyle") &&
          opts.quoteStyle !== "single" &&
          opts.quoteStyle !== "double"
        ) {
          throw new TypeError(
            'option "quoteStyle" must be "single" or "double"',
          )
        }
        if (
          has(opts, "maxStringLength") &&
          (typeof opts.maxStringLength === "number"
            ? opts.maxStringLength < 0 && opts.maxStringLength !== Infinity
            : opts.maxStringLength !== null)
        ) {
          throw new TypeError(
            'option "maxStringLength", if provided, must be a positive integer, Infinity, or `null`',
          )
        }
        var customInspect = has(opts, "customInspect")
          ? opts.customInspect
          : true
        if (typeof customInspect !== "boolean" && customInspect !== "symbol") {
          throw new TypeError(
            "option \"customInspect\", if provided, must be `true`, `false`, or `'symbol'`",
          )
        }
        if (
          has(opts, "indent") &&
          opts.indent !== null &&
          opts.indent !== "\t" &&
          !(parseInt(opts.indent, 10) === opts.indent && opts.indent > 0)
        ) {
          throw new TypeError(
            'option "indent" must be "\\t", an integer > 0, or `null`',
          )
        }
        if (
          has(opts, "numericSeparator") &&
          typeof opts.numericSeparator !== "boolean"
        ) {
          throw new TypeError(
            'option "numericSeparator", if provided, must be `true` or `false`',
          )
        }
        var numericSeparator = opts.numericSeparator
        if (typeof obj === "undefined") {
          return "undefined"
        }
        if (obj === null) {
          return "null"
        }
        if (typeof obj === "boolean") {
          return obj ? "true" : "false"
        }
        if (typeof obj === "string") {
          return inspectString(obj, opts)
        }
        if (typeof obj === "number") {
          if (obj === 0) {
            return Infinity / obj > 0 ? "0" : "-0"
          }
          var str = String(obj)
          return numericSeparator ? addNumericSeparator(obj, str) : str
        }
        if (typeof obj === "bigint") {
          var bigIntStr = String(obj) + "n"
          return numericSeparator
            ? addNumericSeparator(obj, bigIntStr)
            : bigIntStr
        }
        var maxDepth = typeof opts.depth === "undefined" ? 5 : opts.depth
        if (typeof depth === "undefined") {
          depth = 0
        }
        if (depth >= maxDepth && maxDepth > 0 && typeof obj === "object") {
          return isArray(obj) ? "[Array]" : "[Object]"
        }
        var indent = getIndent(opts, depth)
        if (typeof seen === "undefined") {
          seen = []
        } else if (indexOf(seen, obj) >= 0) {
          return "[Circular]"
        }
        function inspect(value, from, noIndent) {
          if (from) {
            seen = $arrSlice.call(seen)
            seen.push(from)
          }
          if (noIndent) {
            var newOpts = {
              depth: opts.depth,
            }
            if (has(opts, "quoteStyle")) {
              newOpts.quoteStyle = opts.quoteStyle
            }
            return inspect_(value, newOpts, depth + 1, seen)
          }
          return inspect_(value, opts, depth + 1, seen)
        }
        if (typeof obj === "function" && !isRegExp(obj)) {
          // in older engines, regexes are callable
          var name = nameOf(obj)
          var keys = arrObjKeys(obj, inspect)
          return (
            "[Function" +
            (name ? ": " + name : " (anonymous)") +
            "]" +
            (keys.length > 0 ? " { " + $join.call(keys, ", ") + " }" : "")
          )
        }
        if (isSymbol(obj)) {
          var symString = hasShammedSymbols
            ? $replace.call(String(obj), /^(Symbol\(.*\))_[^)]*$/, "$1")
            : symToString.call(obj)
          return typeof obj === "object" && !hasShammedSymbols
            ? markBoxed(symString)
            : symString
        }
        if (isElement(obj)) {
          var s = "<" + $toLowerCase.call(String(obj.nodeName))
          var attrs = obj.attributes || []
          for (var i = 0; i < attrs.length; i++) {
            s +=
              " " +
              attrs[i].name +
              "=" +
              wrapQuotes(quote(attrs[i].value), "double", opts)
          }
          s += ">"
          if (obj.childNodes && obj.childNodes.length) {
            s += "..."
          }
          s += "</" + $toLowerCase.call(String(obj.nodeName)) + ">"
          return s
        }
        if (isArray(obj)) {
          if (obj.length === 0) {
            return "[]"
          }
          var xs = arrObjKeys(obj, inspect)
          if (indent && !singleLineValues(xs)) {
            return "[" + indentedJoin(xs, indent) + "]"
          }
          return "[ " + $join.call(xs, ", ") + " ]"
        }
        if (isError(obj)) {
          var parts = arrObjKeys(obj, inspect)
          if (
            !("cause" in Error.prototype) &&
            "cause" in obj &&
            !isEnumerable.call(obj, "cause")
          ) {
            return (
              "{ [" +
              String(obj) +
              "] " +
              $join.call(
                $concat.call("[cause]: " + inspect(obj.cause), parts),
                ", ",
              ) +
              " }"
            )
          }
          if (parts.length === 0) {
            return "[" + String(obj) + "]"
          }
          return "{ [" + String(obj) + "] " + $join.call(parts, ", ") + " }"
        }
        if (typeof obj === "object" && customInspect) {
          if (
            inspectSymbol &&
            typeof obj[inspectSymbol] === "function" &&
            utilInspect
          ) {
            return utilInspect(obj, {
              depth: maxDepth - depth,
            })
          } else if (
            customInspect !== "symbol" &&
            typeof obj.inspect === "function"
          ) {
            return obj.inspect()
          }
        }
        if (isMap(obj)) {
          var mapParts = []
          if (mapForEach) {
            mapForEach.call(obj, function (value, key) {
              mapParts.push(
                inspect(key, obj, true) + " => " + inspect(value, obj),
              )
            })
          }
          return collectionOf("Map", mapSize.call(obj), mapParts, indent)
        }
        if (isSet(obj)) {
          var setParts = []
          if (setForEach) {
            setForEach.call(obj, function (value) {
              setParts.push(inspect(value, obj))
            })
          }
          return collectionOf("Set", setSize.call(obj), setParts, indent)
        }
        if (isWeakMap(obj)) {
          return weakCollectionOf("WeakMap")
        }
        if (isWeakSet(obj)) {
          return weakCollectionOf("WeakSet")
        }
        if (isWeakRef(obj)) {
          return weakCollectionOf("WeakRef")
        }
        if (isNumber(obj)) {
          return markBoxed(inspect(Number(obj)))
        }
        if (isBigInt(obj)) {
          return markBoxed(inspect(bigIntValueOf.call(obj)))
        }
        if (isBoolean(obj)) {
          return markBoxed(booleanValueOf.call(obj))
        }
        if (isString(obj)) {
          return markBoxed(inspect(String(obj)))
        }
        if (!isDate(obj) && !isRegExp(obj)) {
          var ys = arrObjKeys(obj, inspect)
          var isPlainObject = gPO
            ? gPO(obj) === Object.prototype
            : obj instanceof Object || obj.constructor === Object
          var protoTag = obj instanceof Object ? "" : "null prototype"
          var stringTag =
            !isPlainObject &&
            toStringTag &&
            Object(obj) === obj &&
            toStringTag in obj
              ? $slice.call(toStr(obj), 8, -1)
              : protoTag
                ? "Object"
                : ""
          var constructorTag =
            isPlainObject || typeof obj.constructor !== "function"
              ? ""
              : obj.constructor.name
                ? obj.constructor.name + " "
                : ""
          var tag =
            constructorTag +
            (stringTag || protoTag
              ? "[" +
                $join.call(
                  $concat.call([], stringTag || [], protoTag || []),
                  ": ",
                ) +
                "] "
              : "")
          if (ys.length === 0) {
            return tag + "{}"
          }
          if (indent) {
            return tag + "{" + indentedJoin(ys, indent) + "}"
          }
          return tag + "{ " + $join.call(ys, ", ") + " }"
        }
        return String(obj)
      }
      function wrapQuotes(s, defaultStyle, opts) {
        var quoteChar =
          (opts.quoteStyle || defaultStyle) === "double" ? '"' : "'"
        return quoteChar + s + quoteChar
      }
      function quote(s) {
        return $replace.call(String(s), /"/g, "&quot;")
      }
      function isArray(obj) {
        return (
          toStr(obj) === "[object Array]" &&
          (!toStringTag || !(typeof obj === "object" && toStringTag in obj))
        )
      }
      function isDate(obj) {
        return (
          toStr(obj) === "[object Date]" &&
          (!toStringTag || !(typeof obj === "object" && toStringTag in obj))
        )
      }
      function isRegExp(obj) {
        return (
          toStr(obj) === "[object RegExp]" &&
          (!toStringTag || !(typeof obj === "object" && toStringTag in obj))
        )
      }
      function isError(obj) {
        return (
          toStr(obj) === "[object Error]" &&
          (!toStringTag || !(typeof obj === "object" && toStringTag in obj))
        )
      }
      function isString(obj) {
        return (
          toStr(obj) === "[object String]" &&
          (!toStringTag || !(typeof obj === "object" && toStringTag in obj))
        )
      }
      function isNumber(obj) {
        return (
          toStr(obj) === "[object Number]" &&
          (!toStringTag || !(typeof obj === "object" && toStringTag in obj))
        )
      }
      function isBoolean(obj) {
        return (
          toStr(obj) === "[object Boolean]" &&
          (!toStringTag || !(typeof obj === "object" && toStringTag in obj))
        )
      }

      // Symbol and BigInt do have Symbol.toStringTag by spec, so that can't be used to eliminate false positives
      function isSymbol(obj) {
        if (hasShammedSymbols) {
          return obj && typeof obj === "object" && obj instanceof Symbol
        }
        if (typeof obj === "symbol") {
          return true
        }
        if (!obj || typeof obj !== "object" || !symToString) {
          return false
        }
        try {
          symToString.call(obj)
          return true
        } catch (e) {}
        return false
      }
      function isBigInt(obj) {
        if (!obj || typeof obj !== "object" || !bigIntValueOf) {
          return false
        }
        try {
          bigIntValueOf.call(obj)
          return true
        } catch (e) {}
        return false
      }
      var hasOwn =
        Object.prototype.hasOwnProperty ||
        function (key) {
          return key in this
        }
      function has(obj, key) {
        return hasOwn.call(obj, key)
      }
      function toStr(obj) {
        return objectToString.call(obj)
      }
      function nameOf(f) {
        if (f.name) {
          return f.name
        }
        var m = $match.call(functionToString.call(f), /^function\s*([\w$]+)/)
        if (m) {
          return m[1]
        }
        return null
      }
      function indexOf(xs, x) {
        if (xs.indexOf) {
          return xs.indexOf(x)
        }
        for (var i = 0, l = xs.length; i < l; i++) {
          if (xs[i] === x) {
            return i
          }
        }
        return -1
      }
      function isMap(x) {
        if (!mapSize || !x || typeof x !== "object") {
          return false
        }
        try {
          mapSize.call(x)
          try {
            setSize.call(x)
          } catch (s) {
            return true
          }
          return x instanceof Map // core-js workaround, pre-v2.5.0
        } catch (e) {}
        return false
      }
      function isWeakMap(x) {
        if (!weakMapHas || !x || typeof x !== "object") {
          return false
        }
        try {
          weakMapHas.call(x, weakMapHas)
          try {
            weakSetHas.call(x, weakSetHas)
          } catch (s) {
            return true
          }
          return x instanceof WeakMap // core-js workaround, pre-v2.5.0
        } catch (e) {}
        return false
      }
      function isWeakRef(x) {
        if (!weakRefDeref || !x || typeof x !== "object") {
          return false
        }
        try {
          weakRefDeref.call(x)
          return true
        } catch (e) {}
        return false
      }
      function isSet(x) {
        if (!setSize || !x || typeof x !== "object") {
          return false
        }
        try {
          setSize.call(x)
          try {
            mapSize.call(x)
          } catch (m) {
            return true
          }
          return x instanceof Set // core-js workaround, pre-v2.5.0
        } catch (e) {}
        return false
      }
      function isWeakSet(x) {
        if (!weakSetHas || !x || typeof x !== "object") {
          return false
        }
        try {
          weakSetHas.call(x, weakSetHas)
          try {
            weakMapHas.call(x, weakMapHas)
          } catch (s) {
            return true
          }
          return x instanceof WeakSet // core-js workaround, pre-v2.5.0
        } catch (e) {}
        return false
      }
      function isElement(x) {
        if (!x || typeof x !== "object") {
          return false
        }
        if (typeof HTMLElement !== "undefined" && x instanceof HTMLElement) {
          return true
        }
        return (
          typeof x.nodeName === "string" && typeof x.getAttribute === "function"
        )
      }
      function inspectString(str, opts) {
        if (str.length > opts.maxStringLength) {
          var remaining = str.length - opts.maxStringLength
          var trailer =
            "... " + remaining + " more character" + (remaining > 1 ? "s" : "")
          return (
            inspectString($slice.call(str, 0, opts.maxStringLength), opts) +
            trailer
          )
        }
        // eslint-disable-next-line no-control-regex
        var s = $replace.call(
          $replace.call(str, /(['\\])/g, "\\$1"),
          /[\x00-\x1f]/g,
          lowbyte,
        )
        return wrapQuotes(s, "single", opts)
      }
      function lowbyte(c) {
        var n = c.charCodeAt(0)
        var x = {
          8: "b",
          9: "t",
          10: "n",
          12: "f",
          13: "r",
        }[n]
        if (x) {
          return "\\" + x
        }
        return "\\x" + (n < 0x10 ? "0" : "") + $toUpperCase.call(n.toString(16))
      }
      function markBoxed(str) {
        return "Object(" + str + ")"
      }
      function weakCollectionOf(type) {
        return type + " { ? }"
      }
      function collectionOf(type, size, entries, indent) {
        var joinedEntries = indent
          ? indentedJoin(entries, indent)
          : $join.call(entries, ", ")
        return type + " (" + size + ") {" + joinedEntries + "}"
      }
      function singleLineValues(xs) {
        for (var i = 0; i < xs.length; i++) {
          if (indexOf(xs[i], "\n") >= 0) {
            return false
          }
        }
        return true
      }
      function getIndent(opts, depth) {
        var baseIndent
        if (opts.indent === "\t") {
          baseIndent = "\t"
        } else if (typeof opts.indent === "number" && opts.indent > 0) {
          baseIndent = $join.call(Array(opts.indent + 1), " ")
        } else {
          return null
        }
        return {
          base: baseIndent,
          prev: $join.call(Array(depth + 1), baseIndent),
        }
      }
      function indentedJoin(xs, indent) {
        if (xs.length === 0) {
          return ""
        }
        var lineJoiner = "\n" + indent.prev + indent.base
        return (
          lineJoiner + $join.call(xs, "," + lineJoiner) + "\n" + indent.prev
        )
      }
      function arrObjKeys(obj, inspect) {
        var isArr = isArray(obj)
        var xs = []
        if (isArr) {
          xs.length = obj.length
          for (var i = 0; i < obj.length; i++) {
            xs[i] = has(obj, i) ? inspect(obj[i], obj) : ""
          }
        }
        var syms = typeof gOPS === "function" ? gOPS(obj) : []
        var symMap
        if (hasShammedSymbols) {
          symMap = {}
          for (var k = 0; k < syms.length; k++) {
            symMap["$" + syms[k]] = syms[k]
          }
        }
        for (var key in obj) {
          // eslint-disable-line no-restricted-syntax
          if (!has(obj, key)) {
            continue
          } // eslint-disable-line no-restricted-syntax, no-continue
          if (isArr && String(Number(key)) === key && key < obj.length) {
            continue
          } // eslint-disable-line no-restricted-syntax, no-continue
          if (hasShammedSymbols && symMap["$" + key] instanceof Symbol) {
            // this is to prevent shammed Symbols, which are stored as strings, from being included in the string key section
            continue // eslint-disable-line no-restricted-syntax, no-continue
          } else if ($test.call(/[^\w$]/, key)) {
            xs.push(inspect(key, obj) + ": " + inspect(obj[key], obj))
          } else {
            xs.push(key + ": " + inspect(obj[key], obj))
          }
        }
        if (typeof gOPS === "function") {
          for (var j = 0; j < syms.length; j++) {
            if (isEnumerable.call(obj, syms[j])) {
              xs.push(
                "[" + inspect(syms[j]) + "]: " + inspect(obj[syms[j]], obj),
              )
            }
          }
        }
        return xs
      }

      /***/
    },

    /***/ 14375: /***/ (
      module,
      __unused_webpack_exports,
      __webpack_require__,
    ) => {
      "use strict"
      /* provided dependency */ var process = __webpack_require__(71624)
      // 'path' module extracted from Node.js v8.11.1 (only the posix part)
      // transplited with Babel

      // Copyright Joyent, Inc. and other Node contributors.
      //
      // Permission is hereby granted, free of charge, to any person obtaining a
      // copy of this software and associated documentation files (the
      // "Software"), to deal in the Software without restriction, including
      // without limitation the rights to use, copy, modify, merge, publish,
      // distribute, sublicense, and/or sell copies of the Software, and to permit
      // persons to whom the Software is furnished to do so, subject to the
      // following conditions:
      //
      // The above copyright notice and this permission notice shall be included
      // in all copies or substantial portions of the Software.
      //
      // THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
      // OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
      // MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
      // NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
      // DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
      // OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
      // USE OR OTHER DEALINGS IN THE SOFTWARE.

      function assertPath(path) {
        if (typeof path !== "string") {
          throw new TypeError(
            "Path must be a string. Received " + JSON.stringify(path),
          )
        }
      }

      // Resolves . and .. elements in a path with directory names
      function normalizeStringPosix(path, allowAboveRoot) {
        var res = ""
        var lastSegmentLength = 0
        var lastSlash = -1
        var dots = 0
        var code
        for (var i = 0; i <= path.length; ++i) {
          if (i < path.length) code = path.charCodeAt(i)
          else if (code === 47 /*/*/) break
          else code = 47 /*/*/
          if (code === 47 /*/*/) {
            if (lastSlash === i - 1 || dots === 1) {
              // NOOP
            } else if (lastSlash !== i - 1 && dots === 2) {
              if (
                res.length < 2 ||
                lastSegmentLength !== 2 ||
                res.charCodeAt(res.length - 1) !== 46 /*.*/ ||
                res.charCodeAt(res.length - 2) !== 46 /*.*/
              ) {
                if (res.length > 2) {
                  var lastSlashIndex = res.lastIndexOf("/")
                  if (lastSlashIndex !== res.length - 1) {
                    if (lastSlashIndex === -1) {
                      res = ""
                      lastSegmentLength = 0
                    } else {
                      res = res.slice(0, lastSlashIndex)
                      lastSegmentLength = res.length - 1 - res.lastIndexOf("/")
                    }
                    lastSlash = i
                    dots = 0
                    continue
                  }
                } else if (res.length === 2 || res.length === 1) {
                  res = ""
                  lastSegmentLength = 0
                  lastSlash = i
                  dots = 0
                  continue
                }
              }
              if (allowAboveRoot) {
                if (res.length > 0) res += "/.."
                else res = ".."
                lastSegmentLength = 2
              }
            } else {
              if (res.length > 0) res += "/" + path.slice(lastSlash + 1, i)
              else res = path.slice(lastSlash + 1, i)
              lastSegmentLength = i - lastSlash - 1
            }
            lastSlash = i
            dots = 0
          } else if (code === 46 /*.*/ && dots !== -1) {
            ++dots
          } else {
            dots = -1
          }
        }
        return res
      }
      function _format(sep, pathObject) {
        var dir = pathObject.dir || pathObject.root
        var base =
          pathObject.base || (pathObject.name || "") + (pathObject.ext || "")
        if (!dir) {
          return base
        }
        if (dir === pathObject.root) {
          return dir + base
        }
        return dir + sep + base
      }
      var posix = {
        // path.resolve([from ...], to)
        resolve: function resolve() {
          var resolvedPath = ""
          var resolvedAbsolute = false
          var cwd
          for (
            var i = arguments.length - 1;
            i >= -1 && !resolvedAbsolute;
            i--
          ) {
            var path
            if (i >= 0) path = arguments[i]
            else {
              if (cwd === undefined) cwd = process.cwd()
              path = cwd
            }
            assertPath(path)

            // Skip empty entries
            if (path.length === 0) {
              continue
            }
            resolvedPath = path + "/" + resolvedPath
            resolvedAbsolute = path.charCodeAt(0) === 47 /*/*/
          }

          // At this point the path should be resolved to a full absolute path, but
          // handle relative paths to be safe (might happen when process.cwd() fails)

          // Normalize the path
          resolvedPath = normalizeStringPosix(resolvedPath, !resolvedAbsolute)
          if (resolvedAbsolute) {
            if (resolvedPath.length > 0) return "/" + resolvedPath
            else return "/"
          } else if (resolvedPath.length > 0) {
            return resolvedPath
          } else {
            return "."
          }
        },
        normalize: function normalize(path) {
          assertPath(path)
          if (path.length === 0) return "."
          var isAbsolute = path.charCodeAt(0) === 47 /*/*/
          var trailingSeparator = path.charCodeAt(path.length - 1) === 47 /*/*/

          // Normalize the path
          path = normalizeStringPosix(path, !isAbsolute)
          if (path.length === 0 && !isAbsolute) path = "."
          if (path.length > 0 && trailingSeparator) path += "/"
          if (isAbsolute) return "/" + path
          return path
        },
        isAbsolute: function isAbsolute(path) {
          assertPath(path)
          return path.length > 0 && path.charCodeAt(0) === 47 /*/*/
        },

        join: function join() {
          if (arguments.length === 0) return "."
          var joined
          for (var i = 0; i < arguments.length; ++i) {
            var arg = arguments[i]
            assertPath(arg)
            if (arg.length > 0) {
              if (joined === undefined) joined = arg
              else joined += "/" + arg
            }
          }
          if (joined === undefined) return "."
          return posix.normalize(joined)
        },
        relative: function relative(from, to) {
          assertPath(from)
          assertPath(to)
          if (from === to) return ""
          from = posix.resolve(from)
          to = posix.resolve(to)
          if (from === to) return ""

          // Trim any leading backslashes
          var fromStart = 1
          for (; fromStart < from.length; ++fromStart) {
            if (from.charCodeAt(fromStart) !== 47 /*/*/) break
          }
          var fromEnd = from.length
          var fromLen = fromEnd - fromStart

          // Trim any leading backslashes
          var toStart = 1
          for (; toStart < to.length; ++toStart) {
            if (to.charCodeAt(toStart) !== 47 /*/*/) break
          }
          var toEnd = to.length
          var toLen = toEnd - toStart

          // Compare paths to find the longest common path from root
          var length = fromLen < toLen ? fromLen : toLen
          var lastCommonSep = -1
          var i = 0
          for (; i <= length; ++i) {
            if (i === length) {
              if (toLen > length) {
                if (to.charCodeAt(toStart + i) === 47 /*/*/) {
                  // We get here if `from` is the exact base path for `to`.
                  // For example: from='/foo/bar'; to='/foo/bar/baz'
                  return to.slice(toStart + i + 1)
                } else if (i === 0) {
                  // We get here if `from` is the root
                  // For example: from='/'; to='/foo'
                  return to.slice(toStart + i)
                }
              } else if (fromLen > length) {
                if (from.charCodeAt(fromStart + i) === 47 /*/*/) {
                  // We get here if `to` is the exact base path for `from`.
                  // For example: from='/foo/bar/baz'; to='/foo/bar'
                  lastCommonSep = i
                } else if (i === 0) {
                  // We get here if `to` is the root.
                  // For example: from='/foo'; to='/'
                  lastCommonSep = 0
                }
              }
              break
            }
            var fromCode = from.charCodeAt(fromStart + i)
            var toCode = to.charCodeAt(toStart + i)
            if (fromCode !== toCode) break
            else if (fromCode === 47 /*/*/) lastCommonSep = i
          }
          var out = ""
          // Generate the relative path based on the path difference between `to`
          // and `from`
          for (i = fromStart + lastCommonSep + 1; i <= fromEnd; ++i) {
            if (i === fromEnd || from.charCodeAt(i) === 47 /*/*/) {
              if (out.length === 0) out += ".."
              else out += "/.."
            }
          }

          // Lastly, append the rest of the destination (`to`) path that comes after
          // the common path parts
          if (out.length > 0) return out + to.slice(toStart + lastCommonSep)
          else {
            toStart += lastCommonSep
            if (to.charCodeAt(toStart) === 47 /*/*/) ++toStart
            return to.slice(toStart)
          }
        },
        _makeLong: function _makeLong(path) {
          return path
        },
        dirname: function dirname(path) {
          assertPath(path)
          if (path.length === 0) return "."
          var code = path.charCodeAt(0)
          var hasRoot = code === 47 /*/*/
          var end = -1
          var matchedSlash = true
          for (var i = path.length - 1; i >= 1; --i) {
            code = path.charCodeAt(i)
            if (code === 47 /*/*/) {
              if (!matchedSlash) {
                end = i
                break
              }
            } else {
              // We saw the first non-path separator
              matchedSlash = false
            }
          }
          if (end === -1) return hasRoot ? "/" : "."
          if (hasRoot && end === 1) return "//"
          return path.slice(0, end)
        },
        basename: function basename(path, ext) {
          if (ext !== undefined && typeof ext !== "string")
            throw new TypeError('"ext" argument must be a string')
          assertPath(path)
          var start = 0
          var end = -1
          var matchedSlash = true
          var i
          if (
            ext !== undefined &&
            ext.length > 0 &&
            ext.length <= path.length
          ) {
            if (ext.length === path.length && ext === path) return ""
            var extIdx = ext.length - 1
            var firstNonSlashEnd = -1
            for (i = path.length - 1; i >= 0; --i) {
              var code = path.charCodeAt(i)
              if (code === 47 /*/*/) {
                // If we reached a path separator that was not part of a set of path
                // separators at the end of the string, stop now
                if (!matchedSlash) {
                  start = i + 1
                  break
                }
              } else {
                if (firstNonSlashEnd === -1) {
                  // We saw the first non-path separator, remember this index in case
                  // we need it if the extension ends up not matching
                  matchedSlash = false
                  firstNonSlashEnd = i + 1
                }
                if (extIdx >= 0) {
                  // Try to match the explicit extension
                  if (code === ext.charCodeAt(extIdx)) {
                    if (--extIdx === -1) {
                      // We matched the extension, so mark this as the end of our path
                      // component
                      end = i
                    }
                  } else {
                    // Extension does not match, so our result is the entire path
                    // component
                    extIdx = -1
                    end = firstNonSlashEnd
                  }
                }
              }
            }
            if (start === end) end = firstNonSlashEnd
            else if (end === -1) end = path.length
            return path.slice(start, end)
          } else {
            for (i = path.length - 1; i >= 0; --i) {
              if (path.charCodeAt(i) === 47 /*/*/) {
                // If we reached a path separator that was not part of a set of path
                // separators at the end of the string, stop now
                if (!matchedSlash) {
                  start = i + 1
                  break
                }
              } else if (end === -1) {
                // We saw the first non-path separator, mark this as the end of our
                // path component
                matchedSlash = false
                end = i + 1
              }
            }
            if (end === -1) return ""
            return path.slice(start, end)
          }
        },
        extname: function extname(path) {
          assertPath(path)
          var startDot = -1
          var startPart = 0
          var end = -1
          var matchedSlash = true
          // Track the state of characters (if any) we see before our first dot and
          // after any path separator we find
          var preDotState = 0
          for (var i = path.length - 1; i >= 0; --i) {
            var code = path.charCodeAt(i)
            if (code === 47 /*/*/) {
              // If we reached a path separator that was not part of a set of path
              // separators at the end of the string, stop now
              if (!matchedSlash) {
                startPart = i + 1
                break
              }
              continue
            }
            if (end === -1) {
              // We saw the first non-path separator, mark this as the end of our
              // extension
              matchedSlash = false
              end = i + 1
            }
            if (code === 46 /*.*/) {
              // If this is our first dot, mark it as the start of our extension
              if (startDot === -1) startDot = i
              else if (preDotState !== 1) preDotState = 1
            } else if (startDot !== -1) {
              // We saw a non-dot and non-path separator before our dot, so we should
              // have a good chance at having a non-empty extension
              preDotState = -1
            }
          }
          if (
            startDot === -1 ||
            end === -1 ||
            // We saw a non-dot character immediately before the dot
            preDotState === 0 ||
            // The (right-most) trimmed path component is exactly '..'
            (preDotState === 1 &&
              startDot === end - 1 &&
              startDot === startPart + 1)
          ) {
            return ""
          }
          return path.slice(startDot, end)
        },
        format: function format(pathObject) {
          if (pathObject === null || typeof pathObject !== "object") {
            throw new TypeError(
              'The "pathObject" argument must be of type Object. Received type ' +
                typeof pathObject,
            )
          }
          return _format("/", pathObject)
        },
        parse: function parse(path) {
          assertPath(path)
          var ret = {
            root: "",
            dir: "",
            base: "",
            ext: "",
            name: "",
          }
          if (path.length === 0) return ret
          var code = path.charCodeAt(0)
          var isAbsolute = code === 47 /*/*/
          var start
          if (isAbsolute) {
            ret.root = "/"
            start = 1
          } else {
            start = 0
          }
          var startDot = -1
          var startPart = 0
          var end = -1
          var matchedSlash = true
          var i = path.length - 1

          // Track the state of characters (if any) we see before our first dot and
          // after any path separator we find
          var preDotState = 0

          // Get non-dir info
          for (; i >= start; --i) {
            code = path.charCodeAt(i)
            if (code === 47 /*/*/) {
              // If we reached a path separator that was not part of a set of path
              // separators at the end of the string, stop now
              if (!matchedSlash) {
                startPart = i + 1
                break
              }
              continue
            }
            if (end === -1) {
              // We saw the first non-path separator, mark this as the end of our
              // extension
              matchedSlash = false
              end = i + 1
            }
            if (code === 46 /*.*/) {
              // If this is our first dot, mark it as the start of our extension
              if (startDot === -1) startDot = i
              else if (preDotState !== 1) preDotState = 1
            } else if (startDot !== -1) {
              // We saw a non-dot and non-path separator before our dot, so we should
              // have a good chance at having a non-empty extension
              preDotState = -1
            }
          }
          if (
            startDot === -1 ||
            end === -1 ||
            // We saw a non-dot character immediately before the dot
            preDotState === 0 ||
            // The (right-most) trimmed path component is exactly '..'
            (preDotState === 1 &&
              startDot === end - 1 &&
              startDot === startPart + 1)
          ) {
            if (end !== -1) {
              if (startPart === 0 && isAbsolute)
                ret.base = ret.name = path.slice(1, end)
              else ret.base = ret.name = path.slice(startPart, end)
            }
          } else {
            if (startPart === 0 && isAbsolute) {
              ret.name = path.slice(1, startDot)
              ret.base = path.slice(1, end)
            } else {
              ret.name = path.slice(startPart, startDot)
              ret.base = path.slice(startPart, end)
            }
            ret.ext = path.slice(startDot, end)
          }
          if (startPart > 0) ret.dir = path.slice(0, startPart - 1)
          else if (isAbsolute) ret.dir = "/"
          return ret
        },
        sep: "/",
        delimiter: ":",
        win32: null,
        posix: null,
      }
      posix.posix = posix
      module.exports = posix

      /***/
    },

    /***/ 71624: /***/ (module) => {
      // shim for using process in browser
      var process = (module.exports = {})

      // cached from whatever global is present so that test runners that stub it
      // don't break things.  But we need to wrap it in a try catch in case it is
      // wrapped in strict mode code which doesn't define any globals.  It's inside a
      // function because try/catches deoptimize in certain engines.

      var cachedSetTimeout
      var cachedClearTimeout
      function defaultSetTimout() {
        throw new Error("setTimeout has not been defined")
      }
      function defaultClearTimeout() {
        throw new Error("clearTimeout has not been defined")
      }
      ;(function () {
        try {
          if (typeof setTimeout === "function") {
            cachedSetTimeout = setTimeout
          } else {
            cachedSetTimeout = defaultSetTimout
          }
        } catch (e) {
          cachedSetTimeout = defaultSetTimout
        }
        try {
          if (typeof clearTimeout === "function") {
            cachedClearTimeout = clearTimeout
          } else {
            cachedClearTimeout = defaultClearTimeout
          }
        } catch (e) {
          cachedClearTimeout = defaultClearTimeout
        }
      })()
      function runTimeout(fun) {
        if (cachedSetTimeout === setTimeout) {
          //normal enviroments in sane situations
          return setTimeout(fun, 0)
        }
        // if setTimeout wasn't available but was latter defined
        if (
          (cachedSetTimeout === defaultSetTimout || !cachedSetTimeout) &&
          setTimeout
        ) {
          cachedSetTimeout = setTimeout
          return setTimeout(fun, 0)
        }
        try {
          // when when somebody has screwed with setTimeout but no I.E. maddness
          return cachedSetTimeout(fun, 0)
        } catch (e) {
          try {
            // When we are in I.E. but the script has been evaled so I.E. doesn't trust the global object when called normally
            return cachedSetTimeout.call(null, fun, 0)
          } catch (e) {
            // same as above but when it's a version of I.E. that must have the global object for 'this', hopfully our context correct otherwise it will throw a global error
            return cachedSetTimeout.call(this, fun, 0)
          }
        }
      }
      function runClearTimeout(marker) {
        if (cachedClearTimeout === clearTimeout) {
          //normal enviroments in sane situations
          return clearTimeout(marker)
        }
        // if clearTimeout wasn't available but was latter defined
        if (
          (cachedClearTimeout === defaultClearTimeout || !cachedClearTimeout) &&
          clearTimeout
        ) {
          cachedClearTimeout = clearTimeout
          return clearTimeout(marker)
        }
        try {
          // when when somebody has screwed with setTimeout but no I.E. maddness
          return cachedClearTimeout(marker)
        } catch (e) {
          try {
            // When we are in I.E. but the script has been evaled so I.E. doesn't  trust the global object when called normally
            return cachedClearTimeout.call(null, marker)
          } catch (e) {
            // same as above but when it's a version of I.E. that must have the global object for 'this', hopfully our context correct otherwise it will throw a global error.
            // Some versions of I.E. have different rules for clearTimeout vs setTimeout
            return cachedClearTimeout.call(this, marker)
          }
        }
      }
      var queue = []
      var draining = false
      var currentQueue
      var queueIndex = -1
      function cleanUpNextTick() {
        if (!draining || !currentQueue) {
          return
        }
        draining = false
        if (currentQueue.length) {
          queue = currentQueue.concat(queue)
        } else {
          queueIndex = -1
        }
        if (queue.length) {
          drainQueue()
        }
      }
      function drainQueue() {
        if (draining) {
          return
        }
        var timeout = runTimeout(cleanUpNextTick)
        draining = true
        var len = queue.length
        while (len) {
          currentQueue = queue
          queue = []
          while (++queueIndex < len) {
            if (currentQueue) {
              currentQueue[queueIndex].run()
            }
          }
          queueIndex = -1
          len = queue.length
        }
        currentQueue = null
        draining = false
        runClearTimeout(timeout)
      }
      process.nextTick = function (fun) {
        var args = new Array(arguments.length - 1)
        if (arguments.length > 1) {
          for (var i = 1; i < arguments.length; i++) {
            args[i - 1] = arguments[i]
          }
        }
        queue.push(new Item(fun, args))
        if (queue.length === 1 && !draining) {
          runTimeout(drainQueue)
        }
      }

      // v8 likes predictible objects
      function Item(fun, array) {
        this.fun = fun
        this.array = array
      }
      Item.prototype.run = function () {
        this.fun.apply(null, this.array)
      }
      process.title = "browser"
      process.browser = true
      process.env = {}
      process.argv = []
      process.version = "" // empty string to avoid regexp issues
      process.versions = {}
      function noop() {}
      process.on = noop
      process.addListener = noop
      process.once = noop
      process.off = noop
      process.removeListener = noop
      process.removeAllListeners = noop
      process.emit = noop
      process.prependListener = noop
      process.prependOnceListener = noop
      process.listeners = function (name) {
        return []
      }
      process.binding = function (name) {
        throw new Error("process.binding is not supported")
      }
      process.cwd = function () {
        return "/"
      }
      process.chdir = function (dir) {
        throw new Error("process.chdir is not supported")
      }
      process.umask = function () {
        return 0
      }

      /***/
    },

    /***/ 43277: /***/ (
      __unused_webpack_module,
      __webpack_exports__,
      __webpack_require__,
    ) => {
      "use strict"
      __webpack_require__.r(__webpack_exports__)
      /* harmony export */ __webpack_require__.d(__webpack_exports__, {
        /* harmony export */ decode: () => /* binding */ decode,
        /* harmony export */ default: () => __WEBPACK_DEFAULT_EXPORT__,
        /* harmony export */ encode: () => /* binding */ encode,
        /* harmony export */ toASCII: () => /* binding */ toASCII,
        /* harmony export */ toUnicode: () => /* binding */ toUnicode,
        /* harmony export */ ucs2decode: () => /* binding */ ucs2decode,
        /* harmony export */ ucs2encode: () => /* binding */ ucs2encode,
        /* harmony export */
      })

      /** Highest positive signed 32-bit float value */
      const maxInt = 2147483647 // aka. 0x7FFFFFFF or 2^31-1

      /** Bootstring parameters */
      const base = 36
      const tMin = 1
      const tMax = 26
      const skew = 38
      const damp = 700
      const initialBias = 72
      const initialN = 128 // 0x80
      const delimiter = "-" // '\x2D'

      /** Regular expressions */
      const regexPunycode = /^xn--/
      const regexNonASCII = /[^\0-\x7F]/ // Note: U+007F DEL is excluded too.
      const regexSeparators = /[\x2E\u3002\uFF0E\uFF61]/g // RFC 3490 separators

      /** Error messages */
      const errors = {
        overflow: "Overflow: input needs wider integers to process",
        "not-basic": "Illegal input >= 0x80 (not a basic code point)",
        "invalid-input": "Invalid input",
      }

      /** Convenience shortcuts */
      const baseMinusTMin = base - tMin
      const floor = Math.floor
      const stringFromCharCode = String.fromCharCode

      /*--------------------------------------------------------------------------*/

      /**
       * A generic error utility function.
       * @private
       * @param {String} type The error type.
       * @returns {Error} Throws a `RangeError` with the applicable error message.
       */
      function error(type) {
        throw new RangeError(errors[type])
      }

      /**
       * A generic `Array#map` utility function.
       * @private
       * @param {Array} array The array to iterate over.
       * @param {Function} callback The function that gets called for every array
       * item.
       * @returns {Array} A new array of values returned by the callback function.
       */
      function map(array, callback) {
        const result = []
        let length = array.length
        while (length--) {
          result[length] = callback(array[length])
        }
        return result
      }

      /**
       * A simple `Array#map`-like wrapper to work with domain name strings or email
       * addresses.
       * @private
       * @param {String} domain The domain name or email address.
       * @param {Function} callback The function that gets called for every
       * character.
       * @returns {String} A new string of characters returned by the callback
       * function.
       */
      function mapDomain(domain, callback) {
        const parts = domain.split("@")
        let result = ""
        if (parts.length > 1) {
          // In email addresses, only the domain name should be punycoded. Leave
          // the local part (i.e. everything up to `@`) intact.
          result = parts[0] + "@"
          domain = parts[1]
        }
        // Avoid `split(regex)` for IE8 compatibility. See #17.
        domain = domain.replace(regexSeparators, "\x2E")
        const labels = domain.split(".")
        const encoded = map(labels, callback).join(".")
        return result + encoded
      }

      /**
       * Creates an array containing the numeric code points of each Unicode
       * character in the string. While JavaScript uses UCS-2 internally,
       * this function will convert a pair of surrogate halves (each of which
       * UCS-2 exposes as separate characters) into a single code point,
       * matching UTF-16.
       * @see `punycode.ucs2.encode`
       * @see <https://mathiasbynens.be/notes/javascript-encoding>
       * @memberOf punycode.ucs2
       * @name decode
       * @param {String} string The Unicode input string (UCS-2).
       * @returns {Array} The new array of code points.
       */
      function ucs2decode(string) {
        const output = []
        let counter = 0
        const length = string.length
        while (counter < length) {
          const value = string.charCodeAt(counter++)
          if (value >= 0xd800 && value <= 0xdbff && counter < length) {
            // It's a high surrogate, and there is a next character.
            const extra = string.charCodeAt(counter++)
            if ((extra & 0xfc00) == 0xdc00) {
              // Low surrogate.
              output.push(((value & 0x3ff) << 10) + (extra & 0x3ff) + 0x10000)
            } else {
              // It's an unmatched surrogate; only append this code unit, in case the
              // next code unit is the high surrogate of a surrogate pair.
              output.push(value)
              counter--
            }
          } else {
            output.push(value)
          }
        }
        return output
      }

      /**
       * Creates a string based on an array of numeric code points.
       * @see `punycode.ucs2.decode`
       * @memberOf punycode.ucs2
       * @name encode
       * @param {Array} codePoints The array of numeric code points.
       * @returns {String} The new Unicode string (UCS-2).
       */
      const ucs2encode = (codePoints) => String.fromCodePoint(...codePoints)

      /**
       * Converts a basic code point into a digit/integer.
       * @see `digitToBasic()`
       * @private
       * @param {Number} codePoint The basic numeric code point value.
       * @returns {Number} The numeric value of a basic code point (for use in
       * representing integers) in the range `0` to `base - 1`, or `base` if
       * the code point does not represent a value.
       */
      const basicToDigit = function (codePoint) {
        if (codePoint >= 0x30 && codePoint < 0x3a) {
          return 26 + (codePoint - 0x30)
        }
        if (codePoint >= 0x41 && codePoint < 0x5b) {
          return codePoint - 0x41
        }
        if (codePoint >= 0x61 && codePoint < 0x7b) {
          return codePoint - 0x61
        }
        return base
      }

      /**
       * Converts a digit/integer into a basic code point.
       * @see `basicToDigit()`
       * @private
       * @param {Number} digit The numeric value of a basic code point.
       * @returns {Number} The basic code point whose value (when used for
       * representing integers) is `digit`, which needs to be in the range
       * `0` to `base - 1`. If `flag` is non-zero, the uppercase form is
       * used; else, the lowercase form is used. The behavior is undefined
       * if `flag` is non-zero and `digit` has no uppercase form.
       */
      const digitToBasic = function (digit, flag) {
        //  0..25 map to ASCII a..z or A..Z
        // 26..35 map to ASCII 0..9
        return digit + 22 + 75 * (digit < 26) - ((flag != 0) << 5)
      }

      /**
       * Bias adaptation function as per section 3.4 of RFC 3492.
       * https://tools.ietf.org/html/rfc3492#section-3.4
       * @private
       */
      const adapt = function (delta, numPoints, firstTime) {
        let k = 0
        delta = firstTime ? floor(delta / damp) : delta >> 1
        delta += floor(delta / numPoints)
        for (
          ;
          /* no initialization */
          delta > (baseMinusTMin * tMax) >> 1;
          k += base
        ) {
          delta = floor(delta / baseMinusTMin)
        }
        return floor(k + ((baseMinusTMin + 1) * delta) / (delta + skew))
      }

      /**
       * Converts a Punycode string of ASCII-only symbols to a string of Unicode
       * symbols.
       * @memberOf punycode
       * @param {String} input The Punycode string of ASCII-only symbols.
       * @returns {String} The resulting string of Unicode symbols.
       */
      const decode = function (input) {
        // Don't use UCS-2.
        const output = []
        const inputLength = input.length
        let i = 0
        let n = initialN
        let bias = initialBias

        // Handle the basic code points: let `basic` be the number of input code
        // points before the last delimiter, or `0` if there is none, then copy
        // the first basic code points to the output.

        let basic = input.lastIndexOf(delimiter)
        if (basic < 0) {
          basic = 0
        }
        for (let j = 0; j < basic; ++j) {
          // if it's not a basic code point
          if (input.charCodeAt(j) >= 0x80) {
            error("not-basic")
          }
          output.push(input.charCodeAt(j))
        }

        // Main decoding loop: start just after the last delimiter if any basic code
        // points were copied; start at the beginning otherwise.

        for (
          /* no final expression */
          let index = basic > 0 ? basic + 1 : 0;
          index < inputLength;

        ) {
          // `index` is the index of the next character to be consumed.
          // Decode a generalized variable-length integer into `delta`,
          // which gets added to `i`. The overflow checking is easier
          // if we increase `i` as we go, then subtract off its starting
          // value at the end to obtain `delta`.
          const oldi = i
          for (/* no condition */ let w = 1, k = base; ; k += base) {
            if (index >= inputLength) {
              error("invalid-input")
            }
            const digit = basicToDigit(input.charCodeAt(index++))
            if (digit >= base) {
              error("invalid-input")
            }
            if (digit > floor((maxInt - i) / w)) {
              error("overflow")
            }
            i += digit * w
            const t = k <= bias ? tMin : k >= bias + tMax ? tMax : k - bias
            if (digit < t) {
              break
            }
            const baseMinusT = base - t
            if (w > floor(maxInt / baseMinusT)) {
              error("overflow")
            }
            w *= baseMinusT
          }
          const out = output.length + 1
          bias = adapt(i - oldi, out, oldi == 0)

          // `i` was supposed to wrap around from `out` to `0`,
          // incrementing `n` each time, so we'll fix that now:
          if (floor(i / out) > maxInt - n) {
            error("overflow")
          }
          n += floor(i / out)
          i %= out

          // Insert `n` at position `i` of the output.
          output.splice(i++, 0, n)
        }
        return String.fromCodePoint(...output)
      }

      /**
       * Converts a string of Unicode symbols (e.g. a domain name label) to a
       * Punycode string of ASCII-only symbols.
       * @memberOf punycode
       * @param {String} input The string of Unicode symbols.
       * @returns {String} The resulting Punycode string of ASCII-only symbols.
       */
      const encode = function (input) {
        const output = []

        // Convert the input in UCS-2 to an array of Unicode code points.
        input = ucs2decode(input)

        // Cache the length.
        const inputLength = input.length

        // Initialize the state.
        let n = initialN
        let delta = 0
        let bias = initialBias

        // Handle the basic code points.
        for (const currentValue of input) {
          if (currentValue < 0x80) {
            output.push(stringFromCharCode(currentValue))
          }
        }
        const basicLength = output.length
        let handledCPCount = basicLength

        // `handledCPCount` is the number of code points that have been handled;
        // `basicLength` is the number of basic code points.

        // Finish the basic string with a delimiter unless it's empty.
        if (basicLength) {
          output.push(delimiter)
        }

        // Main encoding loop:
        while (handledCPCount < inputLength) {
          // All non-basic code points < n have been handled already. Find the next
          // larger one:
          let m = maxInt
          for (const currentValue of input) {
            if (currentValue >= n && currentValue < m) {
              m = currentValue
            }
          }

          // Increase `delta` enough to advance the decoder's <n,i> state to <m,0>,
          // but guard against overflow.
          const handledCPCountPlusOne = handledCPCount + 1
          if (m - n > floor((maxInt - delta) / handledCPCountPlusOne)) {
            error("overflow")
          }
          delta += (m - n) * handledCPCountPlusOne
          n = m
          for (const currentValue of input) {
            if (currentValue < n && ++delta > maxInt) {
              error("overflow")
            }
            if (currentValue === n) {
              // Represent delta as a generalized variable-length integer.
              let q = delta
              for (/* no condition */ let k = base; ; k += base) {
                const t = k <= bias ? tMin : k >= bias + tMax ? tMax : k - bias
                if (q < t) {
                  break
                }
                const qMinusT = q - t
                const baseMinusT = base - t
                output.push(
                  stringFromCharCode(
                    digitToBasic(t + (qMinusT % baseMinusT), 0),
                  ),
                )
                q = floor(qMinusT / baseMinusT)
              }
              output.push(stringFromCharCode(digitToBasic(q, 0)))
              bias = adapt(
                delta,
                handledCPCountPlusOne,
                handledCPCount === basicLength,
              )
              delta = 0
              ++handledCPCount
            }
          }
          ++delta
          ++n
        }
        return output.join("")
      }

      /**
       * Converts a Punycode string representing a domain name or an email address
       * to Unicode. Only the Punycoded parts of the input will be converted, i.e.
       * it doesn't matter if you call it on a string that has already been
       * converted to Unicode.
       * @memberOf punycode
       * @param {String} input The Punycoded domain name or email address to
       * convert to Unicode.
       * @returns {String} The Unicode representation of the given Punycode
       * string.
       */
      const toUnicode = function (input) {
        return mapDomain(input, function (string) {
          return regexPunycode.test(string)
            ? decode(string.slice(4).toLowerCase())
            : string
        })
      }

      /**
       * Converts a Unicode string representing a domain name or an email address to
       * Punycode. Only the non-ASCII parts of the domain name will be converted,
       * i.e. it doesn't matter if you call it with a domain that's already in
       * ASCII.
       * @memberOf punycode
       * @param {String} input The domain name or email address to convert, as a
       * Unicode string.
       * @returns {String} The Punycode representation of the given domain name or
       * email address.
       */
      const toASCII = function (input) {
        return mapDomain(input, function (string) {
          return regexNonASCII.test(string) ? "xn--" + encode(string) : string
        })
      }

      /*--------------------------------------------------------------------------*/

      /** Define the public API */
      const punycode = {
        /**
         * A string representing the current Punycode.js version number.
         * @memberOf punycode
         * @type String
         */
        version: "2.1.0",
        /**
         * An object of methods to convert from JavaScript's internal character
         * representation (UCS-2) to Unicode code points, and back.
         * @see <https://mathiasbynens.be/notes/javascript-encoding>
         * @memberOf punycode
         * @type Object
         */
        ucs2: {
          decode: ucs2decode,
          encode: ucs2encode,
        },
        decode: decode,
        encode: encode,
        toASCII: toASCII,
        toUnicode: toUnicode,
      }

      /* harmony default export */ const __WEBPACK_DEFAULT_EXPORT__ = punycode

      /***/
    },

    /***/ 43512: /***/ (module) => {
      "use strict"

      var replace = String.prototype.replace
      var percentTwenties = /%20/g
      var Format = {
        RFC1738: "RFC1738",
        RFC3986: "RFC3986",
      }
      module.exports = {
        default: Format.RFC3986,
        formatters: {
          RFC1738: function (value) {
            return replace.call(value, percentTwenties, "+")
          },
          RFC3986: function (value) {
            return String(value)
          },
        },
        RFC1738: Format.RFC1738,
        RFC3986: Format.RFC3986,
      }

      /***/
    },

    /***/ 349: /***/ (
      module,
      __unused_webpack_exports,
      __webpack_require__,
    ) => {
      "use strict"

      var stringify = __webpack_require__(74082)
      var parse = __webpack_require__(48169)
      var formats = __webpack_require__(43512)
      module.exports = {
        formats: formats,
        parse: parse,
        stringify: stringify,
      }

      /***/
    },

    /***/ 48169: /***/ (
      module,
      __unused_webpack_exports,
      __webpack_require__,
    ) => {
      "use strict"

      var utils = __webpack_require__(40775)
      var has = Object.prototype.hasOwnProperty
      var isArray = Array.isArray
      var defaults = {
        allowDots: false,
        allowPrototypes: false,
        allowSparse: false,
        arrayLimit: 20,
        charset: "utf-8",
        charsetSentinel: false,
        comma: false,
        decoder: utils.decode,
        delimiter: "&",
        depth: 5,
        ignoreQueryPrefix: false,
        interpretNumericEntities: false,
        parameterLimit: 1000,
        parseArrays: true,
        plainObjects: false,
        strictNullHandling: false,
      }
      var interpretNumericEntities = function (str) {
        return str.replace(/&#(\d+);/g, function ($0, numberStr) {
          return String.fromCharCode(parseInt(numberStr, 10))
        })
      }
      var parseArrayValue = function (val, options) {
        if (
          val &&
          typeof val === "string" &&
          options.comma &&
          val.indexOf(",") > -1
        ) {
          return val.split(",")
        }
        return val
      }

      // This is what browsers will submit when the ✓ character occurs in an
      // application/x-www-form-urlencoded body and the encoding of the page containing
      // the form is iso-8859-1, or when the submitted form has an accept-charset
      // attribute of iso-8859-1. Presumably also with other charsets that do not contain
      // the ✓ character, such as us-ascii.
      var isoSentinel = "utf8=%26%2310003%3B" // encodeURIComponent('&#10003;')

      // These are the percent-encoded utf-8 octets representing a checkmark, indicating that the request actually is utf-8 encoded.
      var charsetSentinel = "utf8=%E2%9C%93" // encodeURIComponent('✓')

      var parseValues = function parseQueryStringValues(str, options) {
        var obj = {
          __proto__: null,
        }
        var cleanStr = options.ignoreQueryPrefix ? str.replace(/^\?/, "") : str
        var limit =
          options.parameterLimit === Infinity
            ? undefined
            : options.parameterLimit
        var parts = cleanStr.split(options.delimiter, limit)
        var skipIndex = -1 // Keep track of where the utf8 sentinel was found
        var i
        var charset = options.charset
        if (options.charsetSentinel) {
          for (i = 0; i < parts.length; ++i) {
            if (parts[i].indexOf("utf8=") === 0) {
              if (parts[i] === charsetSentinel) {
                charset = "utf-8"
              } else if (parts[i] === isoSentinel) {
                charset = "iso-8859-1"
              }
              skipIndex = i
              i = parts.length // The eslint settings do not allow break;
            }
          }
        }

        for (i = 0; i < parts.length; ++i) {
          if (i === skipIndex) {
            continue
          }
          var part = parts[i]
          var bracketEqualsPos = part.indexOf("]=")
          var pos =
            bracketEqualsPos === -1 ? part.indexOf("=") : bracketEqualsPos + 1
          var key, val
          if (pos === -1) {
            key = options.decoder(part, defaults.decoder, charset, "key")
            val = options.strictNullHandling ? null : ""
          } else {
            key = options.decoder(
              part.slice(0, pos),
              defaults.decoder,
              charset,
              "key",
            )
            val = utils.maybeMap(
              parseArrayValue(part.slice(pos + 1), options),
              function (encodedVal) {
                return options.decoder(
                  encodedVal,
                  defaults.decoder,
                  charset,
                  "value",
                )
              },
            )
          }
          if (
            val &&
            options.interpretNumericEntities &&
            charset === "iso-8859-1"
          ) {
            val = interpretNumericEntities(val)
          }
          if (part.indexOf("[]=") > -1) {
            val = isArray(val) ? [val] : val
          }
          if (has.call(obj, key)) {
            obj[key] = utils.combine(obj[key], val)
          } else {
            obj[key] = val
          }
        }
        return obj
      }
      var parseObject = function (chain, val, options, valuesParsed) {
        var leaf = valuesParsed ? val : parseArrayValue(val, options)
        for (var i = chain.length - 1; i >= 0; --i) {
          var obj
          var root = chain[i]
          if (root === "[]" && options.parseArrays) {
            obj = [].concat(leaf)
          } else {
            obj = options.plainObjects ? Object.create(null) : {}
            var cleanRoot =
              root.charAt(0) === "[" && root.charAt(root.length - 1) === "]"
                ? root.slice(1, -1)
                : root
            var index = parseInt(cleanRoot, 10)
            if (!options.parseArrays && cleanRoot === "") {
              obj = {
                0: leaf,
              }
            } else if (
              !isNaN(index) &&
              root !== cleanRoot &&
              String(index) === cleanRoot &&
              index >= 0 &&
              options.parseArrays &&
              index <= options.arrayLimit
            ) {
              obj = []
              obj[index] = leaf
            } else if (cleanRoot !== "__proto__") {
              obj[cleanRoot] = leaf
            }
          }
          leaf = obj
        }
        return leaf
      }
      var parseKeys = function parseQueryStringKeys(
        givenKey,
        val,
        options,
        valuesParsed,
      ) {
        if (!givenKey) {
          return
        }

        // Transform dot notation to bracket notation
        var key = options.allowDots
          ? givenKey.replace(/\.([^.[]+)/g, "[$1]")
          : givenKey

        // The regex chunks

        var brackets = /(\[[^[\]]*])/
        var child = /(\[[^[\]]*])/g

        // Get the parent

        var segment = options.depth > 0 && brackets.exec(key)
        var parent = segment ? key.slice(0, segment.index) : key

        // Stash the parent if it exists

        var keys = []
        if (parent) {
          // If we aren't using plain objects, optionally prefix keys that would overwrite object prototype properties
          if (!options.plainObjects && has.call(Object.prototype, parent)) {
            if (!options.allowPrototypes) {
              return
            }
          }
          keys.push(parent)
        }

        // Loop through children appending to the array until we hit depth

        var i = 0
        while (
          options.depth > 0 &&
          (segment = child.exec(key)) !== null &&
          i < options.depth
        ) {
          i += 1
          if (
            !options.plainObjects &&
            has.call(Object.prototype, segment[1].slice(1, -1))
          ) {
            if (!options.allowPrototypes) {
              return
            }
          }
          keys.push(segment[1])
        }

        // If there's a remainder, just add whatever is left

        if (segment) {
          keys.push("[" + key.slice(segment.index) + "]")
        }
        return parseObject(keys, val, options, valuesParsed)
      }
      var normalizeParseOptions = function normalizeParseOptions(opts) {
        if (!opts) {
          return defaults
        }
        if (
          opts.decoder !== null &&
          opts.decoder !== undefined &&
          typeof opts.decoder !== "function"
        ) {
          throw new TypeError("Decoder has to be a function.")
        }
        if (
          typeof opts.charset !== "undefined" &&
          opts.charset !== "utf-8" &&
          opts.charset !== "iso-8859-1"
        ) {
          throw new TypeError(
            "The charset option must be either utf-8, iso-8859-1, or undefined",
          )
        }
        var charset =
          typeof opts.charset === "undefined" ? defaults.charset : opts.charset
        return {
          allowDots:
            typeof opts.allowDots === "undefined"
              ? defaults.allowDots
              : !!opts.allowDots,
          allowPrototypes:
            typeof opts.allowPrototypes === "boolean"
              ? opts.allowPrototypes
              : defaults.allowPrototypes,
          allowSparse:
            typeof opts.allowSparse === "boolean"
              ? opts.allowSparse
              : defaults.allowSparse,
          arrayLimit:
            typeof opts.arrayLimit === "number"
              ? opts.arrayLimit
              : defaults.arrayLimit,
          charset: charset,
          charsetSentinel:
            typeof opts.charsetSentinel === "boolean"
              ? opts.charsetSentinel
              : defaults.charsetSentinel,
          comma: typeof opts.comma === "boolean" ? opts.comma : defaults.comma,
          decoder:
            typeof opts.decoder === "function"
              ? opts.decoder
              : defaults.decoder,
          delimiter:
            typeof opts.delimiter === "string" || utils.isRegExp(opts.delimiter)
              ? opts.delimiter
              : defaults.delimiter,
          // eslint-disable-next-line no-implicit-coercion, no-extra-parens
          depth:
            typeof opts.depth === "number" || opts.depth === false
              ? +opts.depth
              : defaults.depth,
          ignoreQueryPrefix: opts.ignoreQueryPrefix === true,
          interpretNumericEntities:
            typeof opts.interpretNumericEntities === "boolean"
              ? opts.interpretNumericEntities
              : defaults.interpretNumericEntities,
          parameterLimit:
            typeof opts.parameterLimit === "number"
              ? opts.parameterLimit
              : defaults.parameterLimit,
          parseArrays: opts.parseArrays !== false,
          plainObjects:
            typeof opts.plainObjects === "boolean"
              ? opts.plainObjects
              : defaults.plainObjects,
          strictNullHandling:
            typeof opts.strictNullHandling === "boolean"
              ? opts.strictNullHandling
              : defaults.strictNullHandling,
        }
      }
      module.exports = function (str, opts) {
        var options = normalizeParseOptions(opts)
        if (str === "" || str === null || typeof str === "undefined") {
          return options.plainObjects ? Object.create(null) : {}
        }
        var tempObj = typeof str === "string" ? parseValues(str, options) : str
        var obj = options.plainObjects ? Object.create(null) : {}

        // Iterate over the keys and setup the new object

        var keys = Object.keys(tempObj)
        for (var i = 0; i < keys.length; ++i) {
          var key = keys[i]
          var newObj = parseKeys(
            key,
            tempObj[key],
            options,
            typeof str === "string",
          )
          obj = utils.merge(obj, newObj, options)
        }
        if (options.allowSparse === true) {
          return obj
        }
        return utils.compact(obj)
      }

      /***/
    },

    /***/ 74082: /***/ (
      module,
      __unused_webpack_exports,
      __webpack_require__,
    ) => {
      "use strict"

      var getSideChannel = __webpack_require__(67546)
      var utils = __webpack_require__(40775)
      var formats = __webpack_require__(43512)
      var has = Object.prototype.hasOwnProperty
      var arrayPrefixGenerators = {
        brackets: function brackets(prefix) {
          return prefix + "[]"
        },
        comma: "comma",
        indices: function indices(prefix, key) {
          return prefix + "[" + key + "]"
        },
        repeat: function repeat(prefix) {
          return prefix
        },
      }
      var isArray = Array.isArray
      var push = Array.prototype.push
      var pushToArray = function (arr, valueOrArray) {
        push.apply(arr, isArray(valueOrArray) ? valueOrArray : [valueOrArray])
      }
      var toISO = Date.prototype.toISOString
      var defaultFormat = formats["default"]
      var defaults = {
        addQueryPrefix: false,
        allowDots: false,
        charset: "utf-8",
        charsetSentinel: false,
        delimiter: "&",
        encode: true,
        encoder: utils.encode,
        encodeValuesOnly: false,
        format: defaultFormat,
        formatter: formats.formatters[defaultFormat],
        // deprecated
        indices: false,
        serializeDate: function serializeDate(date) {
          return toISO.call(date)
        },
        skipNulls: false,
        strictNullHandling: false,
      }
      var isNonNullishPrimitive = function isNonNullishPrimitive(v) {
        return (
          typeof v === "string" ||
          typeof v === "number" ||
          typeof v === "boolean" ||
          typeof v === "symbol" ||
          typeof v === "bigint"
        )
      }
      var sentinel = {}
      var stringify = function stringify(
        object,
        prefix,
        generateArrayPrefix,
        commaRoundTrip,
        strictNullHandling,
        skipNulls,
        encoder,
        filter,
        sort,
        allowDots,
        serializeDate,
        format,
        formatter,
        encodeValuesOnly,
        charset,
        sideChannel,
      ) {
        var obj = object
        var tmpSc = sideChannel
        var step = 0
        var findFlag = false
        while ((tmpSc = tmpSc.get(sentinel)) !== void undefined && !findFlag) {
          // Where object last appeared in the ref tree
          var pos = tmpSc.get(object)
          step += 1
          if (typeof pos !== "undefined") {
            if (pos === step) {
              throw new RangeError("Cyclic object value")
            } else {
              findFlag = true // Break while
            }
          }

          if (typeof tmpSc.get(sentinel) === "undefined") {
            step = 0
          }
        }
        if (typeof filter === "function") {
          obj = filter(prefix, obj)
        } else if (obj instanceof Date) {
          obj = serializeDate(obj)
        } else if (generateArrayPrefix === "comma" && isArray(obj)) {
          obj = utils.maybeMap(obj, function (value) {
            if (value instanceof Date) {
              return serializeDate(value)
            }
            return value
          })
        }
        if (obj === null) {
          if (strictNullHandling) {
            return encoder && !encodeValuesOnly
              ? encoder(prefix, defaults.encoder, charset, "key", format)
              : prefix
          }
          obj = ""
        }
        if (isNonNullishPrimitive(obj) || utils.isBuffer(obj)) {
          if (encoder) {
            var keyValue = encodeValuesOnly
              ? prefix
              : encoder(prefix, defaults.encoder, charset, "key", format)
            return [
              formatter(keyValue) +
                "=" +
                formatter(
                  encoder(obj, defaults.encoder, charset, "value", format),
                ),
            ]
          }
          return [formatter(prefix) + "=" + formatter(String(obj))]
        }
        var values = []
        if (typeof obj === "undefined") {
          return values
        }
        var objKeys
        if (generateArrayPrefix === "comma" && isArray(obj)) {
          // we need to join elements in
          if (encodeValuesOnly && encoder) {
            obj = utils.maybeMap(obj, encoder)
          }
          objKeys = [
            {
              value: obj.length > 0 ? obj.join(",") || null : void undefined,
            },
          ]
        } else if (isArray(filter)) {
          objKeys = filter
        } else {
          var keys = Object.keys(obj)
          objKeys = sort ? keys.sort(sort) : keys
        }
        var adjustedPrefix =
          commaRoundTrip && isArray(obj) && obj.length === 1
            ? prefix + "[]"
            : prefix
        for (var j = 0; j < objKeys.length; ++j) {
          var key = objKeys[j]
          var value =
            typeof key === "object" && typeof key.value !== "undefined"
              ? key.value
              : obj[key]
          if (skipNulls && value === null) {
            continue
          }
          var keyPrefix = isArray(obj)
            ? typeof generateArrayPrefix === "function"
              ? generateArrayPrefix(adjustedPrefix, key)
              : adjustedPrefix
            : adjustedPrefix + (allowDots ? "." + key : "[" + key + "]")
          sideChannel.set(object, step)
          var valueSideChannel = getSideChannel()
          valueSideChannel.set(sentinel, sideChannel)
          pushToArray(
            values,
            stringify(
              value,
              keyPrefix,
              generateArrayPrefix,
              commaRoundTrip,
              strictNullHandling,
              skipNulls,
              generateArrayPrefix === "comma" &&
                encodeValuesOnly &&
                isArray(obj)
                ? null
                : encoder,
              filter,
              sort,
              allowDots,
              serializeDate,
              format,
              formatter,
              encodeValuesOnly,
              charset,
              valueSideChannel,
            ),
          )
        }
        return values
      }
      var normalizeStringifyOptions = function normalizeStringifyOptions(opts) {
        if (!opts) {
          return defaults
        }
        if (
          opts.encoder !== null &&
          typeof opts.encoder !== "undefined" &&
          typeof opts.encoder !== "function"
        ) {
          throw new TypeError("Encoder has to be a function.")
        }
        var charset = opts.charset || defaults.charset
        if (
          typeof opts.charset !== "undefined" &&
          opts.charset !== "utf-8" &&
          opts.charset !== "iso-8859-1"
        ) {
          throw new TypeError(
            "The charset option must be either utf-8, iso-8859-1, or undefined",
          )
        }
        var format = formats["default"]
        if (typeof opts.format !== "undefined") {
          if (!has.call(formats.formatters, opts.format)) {
            throw new TypeError("Unknown format option provided.")
          }
          format = opts.format
        }
        var formatter = formats.formatters[format]
        var filter = defaults.filter
        if (typeof opts.filter === "function" || isArray(opts.filter)) {
          filter = opts.filter
        }
        return {
          addQueryPrefix:
            typeof opts.addQueryPrefix === "boolean"
              ? opts.addQueryPrefix
              : defaults.addQueryPrefix,
          allowDots:
            typeof opts.allowDots === "undefined"
              ? defaults.allowDots
              : !!opts.allowDots,
          charset: charset,
          charsetSentinel:
            typeof opts.charsetSentinel === "boolean"
              ? opts.charsetSentinel
              : defaults.charsetSentinel,
          delimiter:
            typeof opts.delimiter === "undefined"
              ? defaults.delimiter
              : opts.delimiter,
          encode:
            typeof opts.encode === "boolean" ? opts.encode : defaults.encode,
          encoder:
            typeof opts.encoder === "function"
              ? opts.encoder
              : defaults.encoder,
          encodeValuesOnly:
            typeof opts.encodeValuesOnly === "boolean"
              ? opts.encodeValuesOnly
              : defaults.encodeValuesOnly,
          filter: filter,
          format: format,
          formatter: formatter,
          serializeDate:
            typeof opts.serializeDate === "function"
              ? opts.serializeDate
              : defaults.serializeDate,
          skipNulls:
            typeof opts.skipNulls === "boolean"
              ? opts.skipNulls
              : defaults.skipNulls,
          sort: typeof opts.sort === "function" ? opts.sort : null,
          strictNullHandling:
            typeof opts.strictNullHandling === "boolean"
              ? opts.strictNullHandling
              : defaults.strictNullHandling,
        }
      }
      module.exports = function (object, opts) {
        var obj = object
        var options = normalizeStringifyOptions(opts)
        var objKeys
        var filter
        if (typeof options.filter === "function") {
          filter = options.filter
          obj = filter("", obj)
        } else if (isArray(options.filter)) {
          filter = options.filter
          objKeys = filter
        }
        var keys = []
        if (typeof obj !== "object" || obj === null) {
          return ""
        }
        var arrayFormat
        if (opts && opts.arrayFormat in arrayPrefixGenerators) {
          arrayFormat = opts.arrayFormat
        } else if (opts && "indices" in opts) {
          arrayFormat = opts.indices ? "indices" : "repeat"
        } else {
          arrayFormat = "indices"
        }
        var generateArrayPrefix = arrayPrefixGenerators[arrayFormat]
        if (
          opts &&
          "commaRoundTrip" in opts &&
          typeof opts.commaRoundTrip !== "boolean"
        ) {
          throw new TypeError("`commaRoundTrip` must be a boolean, or absent")
        }
        var commaRoundTrip =
          generateArrayPrefix === "comma" && opts && opts.commaRoundTrip
        if (!objKeys) {
          objKeys = Object.keys(obj)
        }
        if (options.sort) {
          objKeys.sort(options.sort)
        }
        var sideChannel = getSideChannel()
        for (var i = 0; i < objKeys.length; ++i) {
          var key = objKeys[i]
          if (options.skipNulls && obj[key] === null) {
            continue
          }
          pushToArray(
            keys,
            stringify(
              obj[key],
              key,
              generateArrayPrefix,
              commaRoundTrip,
              options.strictNullHandling,
              options.skipNulls,
              options.encode ? options.encoder : null,
              options.filter,
              options.sort,
              options.allowDots,
              options.serializeDate,
              options.format,
              options.formatter,
              options.encodeValuesOnly,
              options.charset,
              sideChannel,
            ),
          )
        }
        var joined = keys.join(options.delimiter)
        var prefix = options.addQueryPrefix === true ? "?" : ""
        if (options.charsetSentinel) {
          if (options.charset === "iso-8859-1") {
            // encodeURIComponent('&#10003;'), the "numeric entity" representation of a checkmark
            prefix += "utf8=%26%2310003%3B&"
          } else {
            // encodeURIComponent('✓')
            prefix += "utf8=%E2%9C%93&"
          }
        }
        return joined.length > 0 ? prefix + joined : ""
      }

      /***/
    },

    /***/ 40775: /***/ (
      module,
      __unused_webpack_exports,
      __webpack_require__,
    ) => {
      "use strict"

      var formats = __webpack_require__(43512)
      var has = Object.prototype.hasOwnProperty
      var isArray = Array.isArray
      var hexTable = (function () {
        var array = []
        for (var i = 0; i < 256; ++i) {
          array.push("%" + ((i < 16 ? "0" : "") + i.toString(16)).toUpperCase())
        }
        return array
      })()
      var compactQueue = function compactQueue(queue) {
        while (queue.length > 1) {
          var item = queue.pop()
          var obj = item.obj[item.prop]
          if (isArray(obj)) {
            var compacted = []
            for (var j = 0; j < obj.length; ++j) {
              if (typeof obj[j] !== "undefined") {
                compacted.push(obj[j])
              }
            }
            item.obj[item.prop] = compacted
          }
        }
      }
      var arrayToObject = function arrayToObject(source, options) {
        var obj = options && options.plainObjects ? Object.create(null) : {}
        for (var i = 0; i < source.length; ++i) {
          if (typeof source[i] !== "undefined") {
            obj[i] = source[i]
          }
        }
        return obj
      }
      var merge = function merge(target, source, options) {
        /* eslint no-param-reassign: 0 */
        if (!source) {
          return target
        }
        if (typeof source !== "object") {
          if (isArray(target)) {
            target.push(source)
          } else if (target && typeof target === "object") {
            if (
              (options && (options.plainObjects || options.allowPrototypes)) ||
              !has.call(Object.prototype, source)
            ) {
              target[source] = true
            }
          } else {
            return [target, source]
          }
          return target
        }
        if (!target || typeof target !== "object") {
          return [target].concat(source)
        }
        var mergeTarget = target
        if (isArray(target) && !isArray(source)) {
          mergeTarget = arrayToObject(target, options)
        }
        if (isArray(target) && isArray(source)) {
          source.forEach(function (item, i) {
            if (has.call(target, i)) {
              var targetItem = target[i]
              if (
                targetItem &&
                typeof targetItem === "object" &&
                item &&
                typeof item === "object"
              ) {
                target[i] = merge(targetItem, item, options)
              } else {
                target.push(item)
              }
            } else {
              target[i] = item
            }
          })
          return target
        }
        return Object.keys(source).reduce(function (acc, key) {
          var value = source[key]
          if (has.call(acc, key)) {
            acc[key] = merge(acc[key], value, options)
          } else {
            acc[key] = value
          }
          return acc
        }, mergeTarget)
      }
      var assign = function assignSingleSource(target, source) {
        return Object.keys(source).reduce(function (acc, key) {
          acc[key] = source[key]
          return acc
        }, target)
      }
      var decode = function (str, decoder, charset) {
        var strWithoutPlus = str.replace(/\+/g, " ")
        if (charset === "iso-8859-1") {
          // unescape never throws, no try...catch needed:
          return strWithoutPlus.replace(/%[0-9a-f]{2}/gi, unescape)
        }
        // utf-8
        try {
          return decodeURIComponent(strWithoutPlus)
        } catch (e) {
          return strWithoutPlus
        }
      }
      var encode = function encode(str, defaultEncoder, charset, kind, format) {
        // This code was originally written by Brian White (mscdex) for the io.js core querystring library.
        // It has been adapted here for stricter adherence to RFC 3986
        if (str.length === 0) {
          return str
        }
        var string = str
        if (typeof str === "symbol") {
          string = Symbol.prototype.toString.call(str)
        } else if (typeof str !== "string") {
          string = String(str)
        }
        if (charset === "iso-8859-1") {
          return escape(string).replace(/%u[0-9a-f]{4}/gi, function ($0) {
            return "%26%23" + parseInt($0.slice(2), 16) + "%3B"
          })
        }
        var out = ""
        for (var i = 0; i < string.length; ++i) {
          var c = string.charCodeAt(i)
          if (
            c === 0x2d || // -
            c === 0x2e || // .
            c === 0x5f || // _
            c === 0x7e || // ~
            (c >= 0x30 && c <= 0x39) || // 0-9
            (c >= 0x41 && c <= 0x5a) || // a-z
            (c >= 0x61 && c <= 0x7a) || // A-Z
            (format === formats.RFC1738 && (c === 0x28 || c === 0x29)) // ( )
          ) {
            out += string.charAt(i)
            continue
          }
          if (c < 0x80) {
            out = out + hexTable[c]
            continue
          }
          if (c < 0x800) {
            out =
              out + (hexTable[0xc0 | (c >> 6)] + hexTable[0x80 | (c & 0x3f)])
            continue
          }
          if (c < 0xd800 || c >= 0xe000) {
            out =
              out +
              (hexTable[0xe0 | (c >> 12)] +
                hexTable[0x80 | ((c >> 6) & 0x3f)] +
                hexTable[0x80 | (c & 0x3f)])
            continue
          }
          i += 1
          c = 0x10000 + (((c & 0x3ff) << 10) | (string.charCodeAt(i) & 0x3ff))
          /* eslint operator-linebreak: [2, "before"] */
          out +=
            hexTable[0xf0 | (c >> 18)] +
            hexTable[0x80 | ((c >> 12) & 0x3f)] +
            hexTable[0x80 | ((c >> 6) & 0x3f)] +
            hexTable[0x80 | (c & 0x3f)]
        }
        return out
      }
      var compact = function compact(value) {
        var queue = [
          {
            obj: {
              o: value,
            },
            prop: "o",
          },
        ]
        var refs = []
        for (var i = 0; i < queue.length; ++i) {
          var item = queue[i]
          var obj = item.obj[item.prop]
          var keys = Object.keys(obj)
          for (var j = 0; j < keys.length; ++j) {
            var key = keys[j]
            var val = obj[key]
            if (
              typeof val === "object" &&
              val !== null &&
              refs.indexOf(val) === -1
            ) {
              queue.push({
                obj: obj,
                prop: key,
              })
              refs.push(val)
            }
          }
        }
        compactQueue(queue)
        return value
      }
      var isRegExp = function isRegExp(obj) {
        return Object.prototype.toString.call(obj) === "[object RegExp]"
      }
      var isBuffer = function isBuffer(obj) {
        if (!obj || typeof obj !== "object") {
          return false
        }
        return !!(
          obj.constructor &&
          obj.constructor.isBuffer &&
          obj.constructor.isBuffer(obj)
        )
      }
      var combine = function combine(a, b) {
        return [].concat(a, b)
      }
      var maybeMap = function maybeMap(val, fn) {
        if (isArray(val)) {
          var mapped = []
          for (var i = 0; i < val.length; i += 1) {
            mapped.push(fn(val[i]))
          }
          return mapped
        }
        return fn(val)
      }
      module.exports = {
        arrayToObject: arrayToObject,
        assign: assign,
        combine: combine,
        compact: compact,
        decode: decode,
        encode: encode,
        isBuffer: isBuffer,
        isRegExp: isRegExp,
        maybeMap: maybeMap,
        merge: merge,
      }

      /***/
    },

    /***/ 67546: /***/ (
      module,
      __unused_webpack_exports,
      __webpack_require__,
    ) => {
      "use strict"

      var GetIntrinsic = __webpack_require__(55050)
      var callBound = __webpack_require__(3737)
      var inspect = __webpack_require__(87676)
      var $TypeError = GetIntrinsic("%TypeError%")
      var $WeakMap = GetIntrinsic("%WeakMap%", true)
      var $Map = GetIntrinsic("%Map%", true)
      var $weakMapGet = callBound("WeakMap.prototype.get", true)
      var $weakMapSet = callBound("WeakMap.prototype.set", true)
      var $weakMapHas = callBound("WeakMap.prototype.has", true)
      var $mapGet = callBound("Map.prototype.get", true)
      var $mapSet = callBound("Map.prototype.set", true)
      var $mapHas = callBound("Map.prototype.has", true)

      /*
       * This function traverses the list returning the node corresponding to the
       * given key.
       *
       * That node is also moved to the head of the list, so that if it's accessed
       * again we don't need to traverse the whole list. By doing so, all the recently
       * used nodes can be accessed relatively quickly.
       */
      var listGetNode = function (list, key) {
        // eslint-disable-line consistent-return
        for (var prev = list, curr; (curr = prev.next) !== null; prev = curr) {
          if (curr.key === key) {
            prev.next = curr.next
            curr.next = list.next
            list.next = curr // eslint-disable-line no-param-reassign
            return curr
          }
        }
      }
      var listGet = function (objects, key) {
        var node = listGetNode(objects, key)
        return node && node.value
      }
      var listSet = function (objects, key, value) {
        var node = listGetNode(objects, key)
        if (node) {
          node.value = value
        } else {
          // Prepend the new node to the beginning of the list
          objects.next = {
            // eslint-disable-line no-param-reassign
            key: key,
            next: objects.next,
            value: value,
          }
        }
      }
      var listHas = function (objects, key) {
        return !!listGetNode(objects, key)
      }
      module.exports = function getSideChannel() {
        var $wm
        var $m
        var $o
        var channel = {
          assert: function (key) {
            if (!channel.has(key)) {
              throw new $TypeError(
                "Side channel does not contain " + inspect(key),
              )
            }
          },
          get: function (key) {
            // eslint-disable-line consistent-return
            if (
              $WeakMap &&
              key &&
              (typeof key === "object" || typeof key === "function")
            ) {
              if ($wm) {
                return $weakMapGet($wm, key)
              }
            } else if ($Map) {
              if ($m) {
                return $mapGet($m, key)
              }
            } else {
              if ($o) {
                // eslint-disable-line no-lonely-if
                return listGet($o, key)
              }
            }
          },
          has: function (key) {
            if (
              $WeakMap &&
              key &&
              (typeof key === "object" || typeof key === "function")
            ) {
              if ($wm) {
                return $weakMapHas($wm, key)
              }
            } else if ($Map) {
              if ($m) {
                return $mapHas($m, key)
              }
            } else {
              if ($o) {
                // eslint-disable-line no-lonely-if
                return listHas($o, key)
              }
            }
            return false
          },
          set: function (key, value) {
            if (
              $WeakMap &&
              key &&
              (typeof key === "object" || typeof key === "function")
            ) {
              if (!$wm) {
                $wm = new $WeakMap()
              }
              $weakMapSet($wm, key, value)
            } else if ($Map) {
              if (!$m) {
                $m = new $Map()
              }
              $mapSet($m, key, value)
            } else {
              if (!$o) {
                /*
                 * Initialize the linked list as an empty node, so that we don't have
                 * to special-case handling of the first node: we can always refer to
                 * it as (previous node).next, instead of something like (list).head
                 */
                $o = {
                  key: {},
                  next: null,
                }
              }
              listSet($o, key, value)
            }
          },
        }
        return channel
      }

      /***/
    },

    /***/ 69573: /***/ (
      __unused_webpack_module,
      exports,
      __webpack_require__,
    ) => {
      "use strict"
      /*
       * Copyright Joyent, Inc. and other Node contributors.
       *
       * Permission is hereby granted, free of charge, to any person obtaining a
       * copy of this software and associated documentation files (the
       * "Software"), to deal in the Software without restriction, including
       * without limitation the rights to use, copy, modify, merge, publish,
       * distribute, sublicense, and/or sell copies of the Software, and to permit
       * persons to whom the Software is furnished to do so, subject to the
       * following conditions:
       *
       * The above copyright notice and this permission notice shall be included
       * in all copies or substantial portions of the Software.
       *
       * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
       * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
       * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
       * NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
       * DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
       * OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
       * USE OR OTHER DEALINGS IN THE SOFTWARE.
       */

      var punycode = __webpack_require__(43277)
      function Url() {
        this.protocol = null
        this.slashes = null
        this.auth = null
        this.host = null
        this.port = null
        this.hostname = null
        this.hash = null
        this.search = null
        this.query = null
        this.pathname = null
        this.path = null
        this.href = null
      }

      // Reference: RFC 3986, RFC 1808, RFC 2396

      /*
       * define these here so at least they only have to be
       * compiled once on the first module load.
       */
      var protocolPattern = /^([a-z0-9.+-]+:)/i,
        portPattern = /:[0-9]*$/,
        // Special case for a simple path URL
        simplePathPattern = /^(\/\/?(?!\/)[^?\s]*)(\?[^\s]*)?$/,
        /*
         * RFC 2396: characters reserved for delimiting URLs.
         * We actually just auto-escape these.
         */
        delims = ["<", ">", '"', "`", " ", "\r", "\n", "\t"],
        // RFC 2396: characters not allowed for various reasons.
        unwise = ["{", "}", "|", "\\", "^", "`"].concat(delims),
        // Allowed by RFCs, but cause of XSS attacks.  Always escape these.
        autoEscape = ["'"].concat(unwise),
        /*
         * Characters that are never ever allowed in a hostname.
         * Note that any invalid chars are also handled, but these
         * are the ones that are *expected* to be seen, so we fast-path
         * them.
         */
        nonHostChars = ["%", "/", "?", ";", "#"].concat(autoEscape),
        hostEndingChars = ["/", "?", "#"],
        hostnameMaxLen = 255,
        hostnamePartPattern = /^[+a-z0-9A-Z_-]{0,63}$/,
        hostnamePartStart = /^([+a-z0-9A-Z_-]{0,63})(.*)$/,
        // protocols that can allow "unsafe" and "unwise" chars.
        unsafeProtocol = {
          javascript: true,
          "javascript:": true,
        },
        // protocols that never have a hostname.
        hostlessProtocol = {
          javascript: true,
          "javascript:": true,
        },
        // protocols that always contain a // bit.
        slashedProtocol = {
          http: true,
          https: true,
          ftp: true,
          gopher: true,
          file: true,
          "http:": true,
          "https:": true,
          "ftp:": true,
          "gopher:": true,
          "file:": true,
        },
        querystring = __webpack_require__(349)
      function urlParse(url, parseQueryString, slashesDenoteHost) {
        if (url && typeof url === "object" && url instanceof Url) {
          return url
        }
        var u = new Url()
        u.parse(url, parseQueryString, slashesDenoteHost)
        return u
      }
      Url.prototype.parse = function (
        url,
        parseQueryString,
        slashesDenoteHost,
      ) {
        if (typeof url !== "string") {
          throw new TypeError(
            "Parameter 'url' must be a string, not " + typeof url,
          )
        }

        /*
         * Copy chrome, IE, opera backslash-handling behavior.
         * Back slashes before the query string get converted to forward slashes
         * See: https://code.google.com/p/chromium/issues/detail?id=25916
         */
        var queryIndex = url.indexOf("?"),
          splitter =
            queryIndex !== -1 && queryIndex < url.indexOf("#") ? "?" : "#",
          uSplit = url.split(splitter),
          slashRegex = /\\/g
        uSplit[0] = uSplit[0].replace(slashRegex, "/")
        url = uSplit.join(splitter)
        var rest = url

        /*
         * trim before proceeding.
         * This is to support parse stuff like "  http://foo.com  \n"
         */
        rest = rest.trim()
        if (!slashesDenoteHost && url.split("#").length === 1) {
          // Try fast path regexp
          var simplePath = simplePathPattern.exec(rest)
          if (simplePath) {
            this.path = rest
            this.href = rest
            this.pathname = simplePath[1]
            if (simplePath[2]) {
              this.search = simplePath[2]
              if (parseQueryString) {
                this.query = querystring.parse(this.search.substr(1))
              } else {
                this.query = this.search.substr(1)
              }
            } else if (parseQueryString) {
              this.search = ""
              this.query = {}
            }
            return this
          }
        }
        var proto = protocolPattern.exec(rest)
        if (proto) {
          proto = proto[0]
          var lowerProto = proto.toLowerCase()
          this.protocol = lowerProto
          rest = rest.substr(proto.length)
        }

        /*
         * figure out if it's got a host
         * user@server is *always* interpreted as a hostname, and url
         * resolution will treat //foo/bar as host=foo,path=bar because that's
         * how the browser resolves relative URLs.
         */
        if (slashesDenoteHost || proto || rest.match(/^\/\/[^@/]+@[^@/]+/)) {
          var slashes = rest.substr(0, 2) === "//"
          if (slashes && !(proto && hostlessProtocol[proto])) {
            rest = rest.substr(2)
            this.slashes = true
          }
        }
        if (
          !hostlessProtocol[proto] &&
          (slashes || (proto && !slashedProtocol[proto]))
        ) {
          /*
           * there's a hostname.
           * the first instance of /, ?, ;, or # ends the host.
           *
           * If there is an @ in the hostname, then non-host chars *are* allowed
           * to the left of the last @ sign, unless some host-ending character
           * comes *before* the @-sign.
           * URLs are obnoxious.
           *
           * ex:
           * http://a@b@c/ => user:a@b host:c
           * http://a@b?@c => user:a host:c path:/?@c
           */

          /*
           * v0.12 TODO(isaacs): This is not quite how Chrome does things.
           * Review our test case against browsers more comprehensively.
           */

          // find the first instance of any hostEndingChars
          var hostEnd = -1
          for (var i = 0; i < hostEndingChars.length; i++) {
            var hec = rest.indexOf(hostEndingChars[i])
            if (hec !== -1 && (hostEnd === -1 || hec < hostEnd)) {
              hostEnd = hec
            }
          }

          /*
           * at this point, either we have an explicit point where the
           * auth portion cannot go past, or the last @ char is the decider.
           */
          var auth, atSign
          if (hostEnd === -1) {
            // atSign can be anywhere.
            atSign = rest.lastIndexOf("@")
          } else {
            /*
             * atSign must be in auth portion.
             * http://a@b/c@d => host:b auth:a path:/c@d
             */
            atSign = rest.lastIndexOf("@", hostEnd)
          }

          /*
           * Now we have a portion which is definitely the auth.
           * Pull that off.
           */
          if (atSign !== -1) {
            auth = rest.slice(0, atSign)
            rest = rest.slice(atSign + 1)
            this.auth = decodeURIComponent(auth)
          }

          // the host is the remaining to the left of the first non-host char
          hostEnd = -1
          for (var i = 0; i < nonHostChars.length; i++) {
            var hec = rest.indexOf(nonHostChars[i])
            if (hec !== -1 && (hostEnd === -1 || hec < hostEnd)) {
              hostEnd = hec
            }
          }
          // if we still have not hit it, then the entire thing is a host.
          if (hostEnd === -1) {
            hostEnd = rest.length
          }
          this.host = rest.slice(0, hostEnd)
          rest = rest.slice(hostEnd)

          // pull out port.
          this.parseHost()

          /*
           * we've indicated that there is a hostname,
           * so even if it's empty, it has to be present.
           */
          this.hostname = this.hostname || ""

          /*
           * if hostname begins with [ and ends with ]
           * assume that it's an IPv6 address.
           */
          var ipv6Hostname =
            this.hostname[0] === "[" &&
            this.hostname[this.hostname.length - 1] === "]"

          // validate a little.
          if (!ipv6Hostname) {
            var hostparts = this.hostname.split(/\./)
            for (var i = 0, l = hostparts.length; i < l; i++) {
              var part = hostparts[i]
              if (!part) {
                continue
              }
              if (!part.match(hostnamePartPattern)) {
                var newpart = ""
                for (var j = 0, k = part.length; j < k; j++) {
                  if (part.charCodeAt(j) > 127) {
                    /*
                     * we replace non-ASCII char with a temporary placeholder
                     * we need this to make sure size of hostname is not
                     * broken by replacing non-ASCII by nothing
                     */
                    newpart += "x"
                  } else {
                    newpart += part[j]
                  }
                }
                // we test again with ASCII char only
                if (!newpart.match(hostnamePartPattern)) {
                  var validParts = hostparts.slice(0, i)
                  var notHost = hostparts.slice(i + 1)
                  var bit = part.match(hostnamePartStart)
                  if (bit) {
                    validParts.push(bit[1])
                    notHost.unshift(bit[2])
                  }
                  if (notHost.length) {
                    rest = "/" + notHost.join(".") + rest
                  }
                  this.hostname = validParts.join(".")
                  break
                }
              }
            }
          }
          if (this.hostname.length > hostnameMaxLen) {
            this.hostname = ""
          } else {
            // hostnames are always lower case.
            this.hostname = this.hostname.toLowerCase()
          }
          if (!ipv6Hostname) {
            /*
             * IDNA Support: Returns a punycoded representation of "domain".
             * It only converts parts of the domain name that
             * have non-ASCII characters, i.e. it doesn't matter if
             * you call it with a domain that already is ASCII-only.
             */
            this.hostname = punycode.toASCII(this.hostname)
          }
          var p = this.port ? ":" + this.port : ""
          var h = this.hostname || ""
          this.host = h + p
          this.href += this.host

          /*
           * strip [ and ] from the hostname
           * the host field still retains them, though
           */
          if (ipv6Hostname) {
            this.hostname = this.hostname.substr(1, this.hostname.length - 2)
            if (rest[0] !== "/") {
              rest = "/" + rest
            }
          }
        }

        /*
         * now rest is set to the post-host stuff.
         * chop off any delim chars.
         */
        if (!unsafeProtocol[lowerProto]) {
          /*
           * First, make 100% sure that any "autoEscape" chars get
           * escaped, even if encodeURIComponent doesn't think they
           * need to be.
           */
          for (var i = 0, l = autoEscape.length; i < l; i++) {
            var ae = autoEscape[i]
            if (rest.indexOf(ae) === -1) {
              continue
            }
            var esc = encodeURIComponent(ae)
            if (esc === ae) {
              esc = escape(ae)
            }
            rest = rest.split(ae).join(esc)
          }
        }

        // chop off from the tail first.
        var hash = rest.indexOf("#")
        if (hash !== -1) {
          // got a fragment string.
          this.hash = rest.substr(hash)
          rest = rest.slice(0, hash)
        }
        var qm = rest.indexOf("?")
        if (qm !== -1) {
          this.search = rest.substr(qm)
          this.query = rest.substr(qm + 1)
          if (parseQueryString) {
            this.query = querystring.parse(this.query)
          }
          rest = rest.slice(0, qm)
        } else if (parseQueryString) {
          // no query string, but parseQueryString still requested
          this.search = ""
          this.query = {}
        }
        if (rest) {
          this.pathname = rest
        }
        if (slashedProtocol[lowerProto] && this.hostname && !this.pathname) {
          this.pathname = "/"
        }

        // to support http.request
        if (this.pathname || this.search) {
          var p = this.pathname || ""
          var s = this.search || ""
          this.path = p + s
        }

        // finally, reconstruct the href based on what has been validated.
        this.href = this.format()
        return this
      }

      // format a parsed object into a url string
      function urlFormat(obj) {
        /*
         * ensure it's an object, and not a string url.
         * If it's an obj, this is a no-op.
         * this way, you can call url_format() on strings
         * to clean up potentially wonky urls.
         */
        if (typeof obj === "string") {
          obj = urlParse(obj)
        }
        if (!(obj instanceof Url)) {
          return Url.prototype.format.call(obj)
        }
        return obj.format()
      }
      Url.prototype.format = function () {
        var auth = this.auth || ""
        if (auth) {
          auth = encodeURIComponent(auth)
          auth = auth.replace(/%3A/i, ":")
          auth += "@"
        }
        var protocol = this.protocol || "",
          pathname = this.pathname || "",
          hash = this.hash || "",
          host = false,
          query = ""
        if (this.host) {
          host = auth + this.host
        } else if (this.hostname) {
          host =
            auth +
            (this.hostname.indexOf(":") === -1
              ? this.hostname
              : "[" + this.hostname + "]")
          if (this.port) {
            host += ":" + this.port
          }
        }
        if (
          this.query &&
          typeof this.query === "object" &&
          Object.keys(this.query).length
        ) {
          query = querystring.stringify(this.query)
        }
        var search = this.search || (query && "?" + query) || ""
        if (protocol && protocol.substr(-1) !== ":") {
          protocol += ":"
        }

        /*
         * only the slashedProtocols get the //.  Not mailto:, xmpp:, etc.
         * unless they had them to begin with.
         */
        if (
          this.slashes ||
          ((!protocol || slashedProtocol[protocol]) && host !== false)
        ) {
          host = "//" + (host || "")
          if (pathname && pathname.charAt(0) !== "/") {
            pathname = "/" + pathname
          }
        } else if (!host) {
          host = ""
        }
        if (hash && hash.charAt(0) !== "#") {
          hash = "#" + hash
        }
        if (search && search.charAt(0) !== "?") {
          search = "?" + search
        }
        pathname = pathname.replace(/[?#]/g, function (match) {
          return encodeURIComponent(match)
        })
        search = search.replace("#", "%23")
        return protocol + host + pathname + search + hash
      }
      function urlResolve(source, relative) {
        return urlParse(source, false, true).resolve(relative)
      }
      Url.prototype.resolve = function (relative) {
        return this.resolveObject(urlParse(relative, false, true)).format()
      }
      function urlResolveObject(source, relative) {
        if (!source) {
          return relative
        }
        return urlParse(source, false, true).resolveObject(relative)
      }
      Url.prototype.resolveObject = function (relative) {
        if (typeof relative === "string") {
          var rel = new Url()
          rel.parse(relative, false, true)
          relative = rel
        }
        var result = new Url()
        var tkeys = Object.keys(this)
        for (var tk = 0; tk < tkeys.length; tk++) {
          var tkey = tkeys[tk]
          result[tkey] = this[tkey]
        }

        /*
         * hash is always overridden, no matter what.
         * even href="" will remove it.
         */
        result.hash = relative.hash

        // if the relative url is empty, then there's nothing left to do here.
        if (relative.href === "") {
          result.href = result.format()
          return result
        }

        // hrefs like //foo/bar always cut to the protocol.
        if (relative.slashes && !relative.protocol) {
          // take everything except the protocol from relative
          var rkeys = Object.keys(relative)
          for (var rk = 0; rk < rkeys.length; rk++) {
            var rkey = rkeys[rk]
            if (rkey !== "protocol") {
              result[rkey] = relative[rkey]
            }
          }

          // urlParse appends trailing / to urls like http://www.example.com
          if (
            slashedProtocol[result.protocol] &&
            result.hostname &&
            !result.pathname
          ) {
            result.pathname = "/"
            result.path = result.pathname
          }
          result.href = result.format()
          return result
        }
        if (relative.protocol && relative.protocol !== result.protocol) {
          /*
           * if it's a known url protocol, then changing
           * the protocol does weird things
           * first, if it's not file:, then we MUST have a host,
           * and if there was a path
           * to begin with, then we MUST have a path.
           * if it is file:, then the host is dropped,
           * because that's known to be hostless.
           * anything else is assumed to be absolute.
           */
          if (!slashedProtocol[relative.protocol]) {
            var keys = Object.keys(relative)
            for (var v = 0; v < keys.length; v++) {
              var k = keys[v]
              result[k] = relative[k]
            }
            result.href = result.format()
            return result
          }
          result.protocol = relative.protocol
          if (!relative.host && !hostlessProtocol[relative.protocol]) {
            var relPath = (relative.pathname || "").split("/")
            while (relPath.length && !(relative.host = relPath.shift())) {}
            if (!relative.host) {
              relative.host = ""
            }
            if (!relative.hostname) {
              relative.hostname = ""
            }
            if (relPath[0] !== "") {
              relPath.unshift("")
            }
            if (relPath.length < 2) {
              relPath.unshift("")
            }
            result.pathname = relPath.join("/")
          } else {
            result.pathname = relative.pathname
          }
          result.search = relative.search
          result.query = relative.query
          result.host = relative.host || ""
          result.auth = relative.auth
          result.hostname = relative.hostname || relative.host
          result.port = relative.port
          // to support http.request
          if (result.pathname || result.search) {
            var p = result.pathname || ""
            var s = result.search || ""
            result.path = p + s
          }
          result.slashes = result.slashes || relative.slashes
          result.href = result.format()
          return result
        }
        var isSourceAbs = result.pathname && result.pathname.charAt(0) === "/",
          isRelAbs =
            relative.host ||
            (relative.pathname && relative.pathname.charAt(0) === "/"),
          mustEndAbs =
            isRelAbs || isSourceAbs || (result.host && relative.pathname),
          removeAllDots = mustEndAbs,
          srcPath = (result.pathname && result.pathname.split("/")) || [],
          relPath = (relative.pathname && relative.pathname.split("/")) || [],
          psychotic = result.protocol && !slashedProtocol[result.protocol]

        /*
         * if the url is a non-slashed url, then relative
         * links like ../.. should be able
         * to crawl up to the hostname, as well.  This is strange.
         * result.protocol has already been set by now.
         * Later on, put the first path part into the host field.
         */
        if (psychotic) {
          result.hostname = ""
          result.port = null
          if (result.host) {
            if (srcPath[0] === "") {
              srcPath[0] = result.host
            } else {
              srcPath.unshift(result.host)
            }
          }
          result.host = ""
          if (relative.protocol) {
            relative.hostname = null
            relative.port = null
            if (relative.host) {
              if (relPath[0] === "") {
                relPath[0] = relative.host
              } else {
                relPath.unshift(relative.host)
              }
            }
            relative.host = null
          }
          mustEndAbs = mustEndAbs && (relPath[0] === "" || srcPath[0] === "")
        }
        if (isRelAbs) {
          // it's absolute.
          result.host =
            relative.host || relative.host === "" ? relative.host : result.host
          result.hostname =
            relative.hostname || relative.hostname === ""
              ? relative.hostname
              : result.hostname
          result.search = relative.search
          result.query = relative.query
          srcPath = relPath
          // fall through to the dot-handling below.
        } else if (relPath.length) {
          /*
           * it's relative
           * throw away the existing file, and take the new path instead.
           */
          if (!srcPath) {
            srcPath = []
          }
          srcPath.pop()
          srcPath = srcPath.concat(relPath)
          result.search = relative.search
          result.query = relative.query
        } else if (relative.search != null) {
          /*
           * just pull out the search.
           * like href='?foo'.
           * Put this after the other two cases because it simplifies the booleans
           */
          if (psychotic) {
            result.host = srcPath.shift()
            result.hostname = result.host
            /*
             * occationaly the auth can get stuck only in host
             * this especially happens in cases like
             * url.resolveObject('mailto:local1@domain1', 'local2@domain2')
             */
            var authInHost =
              result.host && result.host.indexOf("@") > 0
                ? result.host.split("@")
                : false
            if (authInHost) {
              result.auth = authInHost.shift()
              result.hostname = authInHost.shift()
              result.host = result.hostname
            }
          }
          result.search = relative.search
          result.query = relative.query
          // to support http.request
          if (result.pathname !== null || result.search !== null) {
            result.path =
              (result.pathname ? result.pathname : "") +
              (result.search ? result.search : "")
          }
          result.href = result.format()
          return result
        }
        if (!srcPath.length) {
          /*
           * no path at all.  easy.
           * we've already handled the other stuff above.
           */
          result.pathname = null
          // to support http.request
          if (result.search) {
            result.path = "/" + result.search
          } else {
            result.path = null
          }
          result.href = result.format()
          return result
        }

        /*
         * if a url ENDs in . or .., then it must get a trailing slash.
         * however, if it ends in anything else non-slashy,
         * then it must NOT get a trailing slash.
         */
        var last = srcPath.slice(-1)[0]
        var hasTrailingSlash =
          ((result.host || relative.host || srcPath.length > 1) &&
            (last === "." || last === "..")) ||
          last === ""

        /*
         * strip single dots, resolve double dots to parent dir
         * if the path tries to go above the root, `up` ends up > 0
         */
        var up = 0
        for (var i = srcPath.length; i >= 0; i--) {
          last = srcPath[i]
          if (last === ".") {
            srcPath.splice(i, 1)
          } else if (last === "..") {
            srcPath.splice(i, 1)
            up++
          } else if (up) {
            srcPath.splice(i, 1)
            up--
          }
        }

        // if the path is allowed to go above the root, restore leading ..s
        if (!mustEndAbs && !removeAllDots) {
          for (; up--; up) {
            srcPath.unshift("..")
          }
        }
        if (
          mustEndAbs &&
          srcPath[0] !== "" &&
          (!srcPath[0] || srcPath[0].charAt(0) !== "/")
        ) {
          srcPath.unshift("")
        }
        if (hasTrailingSlash && srcPath.join("/").substr(-1) !== "/") {
          srcPath.push("")
        }
        var isAbsolute =
          srcPath[0] === "" || (srcPath[0] && srcPath[0].charAt(0) === "/")

        // put the host back
        if (psychotic) {
          result.hostname = isAbsolute
            ? ""
            : srcPath.length
              ? srcPath.shift()
              : ""
          result.host = result.hostname
          /*
           * occationaly the auth can get stuck only in host
           * this especially happens in cases like
           * url.resolveObject('mailto:local1@domain1', 'local2@domain2')
           */
          var authInHost =
            result.host && result.host.indexOf("@") > 0
              ? result.host.split("@")
              : false
          if (authInHost) {
            result.auth = authInHost.shift()
            result.hostname = authInHost.shift()
            result.host = result.hostname
          }
        }
        mustEndAbs = mustEndAbs || (result.host && srcPath.length)
        if (mustEndAbs && !isAbsolute) {
          srcPath.unshift("")
        }
        if (srcPath.length > 0) {
          result.pathname = srcPath.join("/")
        } else {
          result.pathname = null
          result.path = null
        }

        // to support request.http
        if (result.pathname !== null || result.search !== null) {
          result.path =
            (result.pathname ? result.pathname : "") +
            (result.search ? result.search : "")
        }
        result.auth = relative.auth || result.auth
        result.slashes = result.slashes || relative.slashes
        result.href = result.format()
        return result
      }
      Url.prototype.parseHost = function () {
        var host = this.host
        var port = portPattern.exec(host)
        if (port) {
          port = port[0]
          if (port !== ":") {
            this.port = port.substr(1)
          }
          host = host.substr(0, host.length - port.length)
        }
        if (host) {
          this.hostname = host
        }
      }
      exports.parse = urlParse
      exports.resolve = urlResolve
      exports.resolveObject = urlResolveObject
      exports.format = urlFormat
      exports.Url = Url

      /***/
    },

    /***/ 53260: /***/ () => {
      /* (ignored) */
      /***/
    },

    /******/
  }
  /************************************************************************/
  /******/ // The module cache
  /******/ var __webpack_module_cache__ = {}
  /******/
  /******/ // The require function
  /******/ function __webpack_require__(moduleId) {
    /******/ // Check if module is in cache
    /******/ var cachedModule = __webpack_module_cache__[moduleId]
    /******/ if (cachedModule !== undefined) {
      /******/ return cachedModule.exports
      /******/
    }
    /******/ // Create a new module (and put it into the cache)
    /******/ var module = (__webpack_module_cache__[moduleId] = {
      /******/ // no module.id needed
      /******/ // no module.loaded needed
      /******/ exports: {},
      /******/
    })
    /******/
    /******/ // Execute the module function
    /******/ __webpack_modules__[moduleId](
      module,
      module.exports,
      __webpack_require__,
    )
    /******/
    /******/ // Return the exports of the module
    /******/ return module.exports
    /******/
  }
  /******/
  /************************************************************************/
  /******/ /* webpack/runtime/define property getters */
  /******/ ;(() => {
    /******/ // define getter functions for harmony exports
    /******/ __webpack_require__.d = (exports, definition) => {
      /******/ for (var key in definition) {
        /******/ if (
          __webpack_require__.o(definition, key) &&
          !__webpack_require__.o(exports, key)
        ) {
          /******/ Object.defineProperty(exports, key, {
            enumerable: true,
            get: definition[key],
          })
          /******/
        }
        /******/
      }
      /******/
    }
    /******/
  })()
  /******/
  /******/ /* webpack/runtime/global */
  /******/
  ;(() => {
    /******/ __webpack_require__.g = (function () {
      /******/ if (typeof globalThis === "object") return globalThis
      /******/ try {
        /******/ return this || new Function("return this")()
        /******/
      } catch (e) {
        /******/ if (typeof window === "object") return window
        /******/
      }
      /******/
    })()
    /******/
  })()
  /******/
  /******/ /* webpack/runtime/hasOwnProperty shorthand */
  /******/
  ;(() => {
    /******/ __webpack_require__.o = (obj, prop) =>
      Object.prototype.hasOwnProperty.call(obj, prop)
    /******/
  })()
  /******/
  /******/ /* webpack/runtime/make namespace object */
  /******/
  ;(() => {
    /******/ // define __esModule on exports
    /******/ __webpack_require__.r = (exports) => {
      /******/ if (typeof Symbol !== "undefined" && Symbol.toStringTag) {
        /******/ Object.defineProperty(exports, Symbol.toStringTag, {
          value: "Module",
        })
        /******/
      }
      /******/ Object.defineProperty(exports, "__esModule", { value: true })
      /******/
    }
    /******/
  })()
  /******/
  /************************************************************************/
  var __webpack_exports__ = {}
  // This entry need to be wrapped in an IIFE because it need to be in strict mode.
  ;(() => {
    "use strict" // CONCATENATED MODULE: ../../libs/common/src/vault/abstractions/fido2/fido2-client.service.abstraction.ts

    const UserRequestedFallbackAbortReason = "UserRequestedFallback"
    /**
     * This class represents an abstraction of the WebAuthn Client as described by W3C:
     * https://www.w3.org/TR/webauthn-3/#webauthn-client
     *
     * The WebAuthn Client is an intermediary entity typically implemented in the user agent
     * (in whole, or in part). Conceptually, it underlies the Web Authentication API and embodies
     * the implementation of the Web Authentication API's operations.
     *
     * It is responsible for both marshalling the inputs for the underlying authenticator operations,
     * and for returning the results of the latter operations to the Web Authentication API's callers.
     */
    class Fido2ClientService {}
    /**
     * Error thrown when the user requests a fallback to the browser's built-in WebAuthn implementation.
     */
    class FallbackRequestedError extends Error {
      constructor() {
        super("FallbackRequested")
        this.fallbackRequested = true
      }
    }

    // EXTERNAL MODULE: ../../node_modules/path-browserify/index.js
    var path_browserify = __webpack_require__(14375) // CONCATENATED MODULE: ../../node_modules/rxjs/dist/esm5/internal/util/isFunction.js
    function isFunction_isFunction(value) {
      return typeof value === "function"
    } // CONCATENATED MODULE: ../../node_modules/rxjs/dist/esm5/internal/util/isScheduler.js
    function isScheduler(value) {
      return value && isFunction_isFunction(value.schedule)
    } // CONCATENATED MODULE: ../../node_modules/rxjs/dist/esm5/internal/util/args.js
    function last(arr) {
      return arr[arr.length - 1]
    }
    function popResultSelector(args) {
      return isFunction(last(args)) ? args.pop() : undefined
    }
    function popScheduler(args) {
      return isScheduler(last(args)) ? args.pop() : undefined
    }
    function popNumber(args, defaultValue) {
      return typeof last(args) === "number" ? args.pop() : defaultValue
    } // CONCATENATED MODULE: ../../node_modules/tslib/tslib.es6.js
    /******************************************************************************
Copyright (c) Microsoft Corporation.

Permission to use, copy, modify, and/or distribute this software for any
purpose with or without fee is hereby granted.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
PERFORMANCE OF THIS SOFTWARE.
***************************************************************************** */
    /* global Reflect, Promise */

    var extendStatics = function (d, b) {
      extendStatics =
        Object.setPrototypeOf ||
        ({
          __proto__: [],
        } instanceof Array &&
          function (d, b) {
            d.__proto__ = b
          }) ||
        function (d, b) {
          for (var p in b)
            if (Object.prototype.hasOwnProperty.call(b, p)) d[p] = b[p]
        }
      return extendStatics(d, b)
    }
    function __extends(d, b) {
      if (typeof b !== "function" && b !== null)
        throw new TypeError(
          "Class extends value " + String(b) + " is not a constructor or null",
        )
      extendStatics(d, b)
      function __() {
        this.constructor = d
      }
      d.prototype =
        b === null ? Object.create(b) : ((__.prototype = b.prototype), new __())
    }
    var __assign = function () {
      __assign =
        Object.assign ||
        function __assign(t) {
          for (var s, i = 1, n = arguments.length; i < n; i++) {
            s = arguments[i]
            for (var p in s)
              if (Object.prototype.hasOwnProperty.call(s, p)) t[p] = s[p]
          }
          return t
        }
      return __assign.apply(this, arguments)
    }
    function __rest(s, e) {
      var t = {}
      for (var p in s)
        if (Object.prototype.hasOwnProperty.call(s, p) && e.indexOf(p) < 0)
          t[p] = s[p]
      if (s != null && typeof Object.getOwnPropertySymbols === "function")
        for (
          var i = 0, p = Object.getOwnPropertySymbols(s);
          i < p.length;
          i++
        ) {
          if (
            e.indexOf(p[i]) < 0 &&
            Object.prototype.propertyIsEnumerable.call(s, p[i])
          )
            t[p[i]] = s[p[i]]
        }
      return t
    }
    function __decorate(decorators, target, key, desc) {
      var c = arguments.length,
        r =
          c < 3
            ? target
            : desc === null
              ? (desc = Object.getOwnPropertyDescriptor(target, key))
              : desc,
        d
      if (typeof Reflect === "object" && typeof Reflect.decorate === "function")
        r = Reflect.decorate(decorators, target, key, desc)
      else
        for (var i = decorators.length - 1; i >= 0; i--)
          if ((d = decorators[i]))
            r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r
      return c > 3 && r && Object.defineProperty(target, key, r), r
    }
    function __param(paramIndex, decorator) {
      return function (target, key) {
        decorator(target, key, paramIndex)
      }
    }
    function __esDecorate(
      ctor,
      descriptorIn,
      decorators,
      contextIn,
      initializers,
      extraInitializers,
    ) {
      function accept(f) {
        if (f !== void 0 && typeof f !== "function")
          throw new TypeError("Function expected")
        return f
      }
      var kind = contextIn.kind,
        key = kind === "getter" ? "get" : kind === "setter" ? "set" : "value"
      var target =
        !descriptorIn && ctor
          ? contextIn["static"]
            ? ctor
            : ctor.prototype
          : null
      var descriptor =
        descriptorIn ||
        (target ? Object.getOwnPropertyDescriptor(target, contextIn.name) : {})
      var _,
        done = false
      for (var i = decorators.length - 1; i >= 0; i--) {
        var context = {}
        for (var p in contextIn) context[p] = p === "access" ? {} : contextIn[p]
        for (var p in contextIn.access) context.access[p] = contextIn.access[p]
        context.addInitializer = function (f) {
          if (done)
            throw new TypeError(
              "Cannot add initializers after decoration has completed",
            )
          extraInitializers.push(accept(f || null))
        }
        var result = (0, decorators[i])(
          kind === "accessor"
            ? {
                get: descriptor.get,
                set: descriptor.set,
              }
            : descriptor[key],
          context,
        )
        if (kind === "accessor") {
          if (result === void 0) continue
          if (result === null || typeof result !== "object")
            throw new TypeError("Object expected")
          if ((_ = accept(result.get))) descriptor.get = _
          if ((_ = accept(result.set))) descriptor.set = _
          if ((_ = accept(result.init))) initializers.push(_)
        } else if ((_ = accept(result))) {
          if (kind === "field") initializers.push(_)
          else descriptor[key] = _
        }
      }
      if (target) Object.defineProperty(target, contextIn.name, descriptor)
      done = true
    }
    function __runInitializers(thisArg, initializers, value) {
      var useValue = arguments.length > 2
      for (var i = 0; i < initializers.length; i++) {
        value = useValue
          ? initializers[i].call(thisArg, value)
          : initializers[i].call(thisArg)
      }
      return useValue ? value : void 0
    }
    function __propKey(x) {
      return typeof x === "symbol" ? x : "".concat(x)
    }
    function __setFunctionName(f, name, prefix) {
      if (typeof name === "symbol")
        name = name.description ? "[".concat(name.description, "]") : ""
      return Object.defineProperty(f, "name", {
        configurable: true,
        value: prefix ? "".concat(prefix, " ", name) : name,
      })
    }
    function __metadata(metadataKey, metadataValue) {
      if (typeof Reflect === "object" && typeof Reflect.metadata === "function")
        return Reflect.metadata(metadataKey, metadataValue)
    }
    function __awaiter(thisArg, _arguments, P, generator) {
      function adopt(value) {
        return value instanceof P
          ? value
          : new P(function (resolve) {
              resolve(value)
            })
      }
      return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) {
          try {
            step(generator.next(value))
          } catch (e) {
            reject(e)
          }
        }
        function rejected(value) {
          try {
            step(generator["throw"](value))
          } catch (e) {
            reject(e)
          }
        }
        function step(result) {
          result.done
            ? resolve(result.value)
            : adopt(result.value).then(fulfilled, rejected)
        }
        step((generator = generator.apply(thisArg, _arguments || [])).next())
      })
    }
    function __generator(thisArg, body) {
      var _ = {
          label: 0,
          sent: function () {
            if (t[0] & 1) throw t[1]
            return t[1]
          },
          trys: [],
          ops: [],
        },
        f,
        y,
        t,
        g
      return (
        (g = {
          next: verb(0),
          throw: verb(1),
          return: verb(2),
        }),
        typeof Symbol === "function" &&
          (g[Symbol.iterator] = function () {
            return this
          }),
        g
      )
      function verb(n) {
        return function (v) {
          return step([n, v])
        }
      }
      function step(op) {
        if (f) throw new TypeError("Generator is already executing.")
        while ((g && ((g = 0), op[0] && (_ = 0)), _))
          try {
            if (
              ((f = 1),
              y &&
                (t =
                  op[0] & 2
                    ? y["return"]
                    : op[0]
                      ? y["throw"] || ((t = y["return"]) && t.call(y), 0)
                      : y.next) &&
                !(t = t.call(y, op[1])).done)
            )
              return t
            if (((y = 0), t)) op = [op[0] & 2, t.value]
            switch (op[0]) {
              case 0:
              case 1:
                t = op
                break
              case 4:
                _.label++
                return {
                  value: op[1],
                  done: false,
                }
              case 5:
                _.label++
                y = op[1]
                op = [0]
                continue
              case 7:
                op = _.ops.pop()
                _.trys.pop()
                continue
              default:
                if (
                  !((t = _.trys), (t = t.length > 0 && t[t.length - 1])) &&
                  (op[0] === 6 || op[0] === 2)
                ) {
                  _ = 0
                  continue
                }
                if (op[0] === 3 && (!t || (op[1] > t[0] && op[1] < t[3]))) {
                  _.label = op[1]
                  break
                }
                if (op[0] === 6 && _.label < t[1]) {
                  _.label = t[1]
                  t = op
                  break
                }
                if (t && _.label < t[2]) {
                  _.label = t[2]
                  _.ops.push(op)
                  break
                }
                if (t[2]) _.ops.pop()
                _.trys.pop()
                continue
            }
            op = body.call(thisArg, _)
          } catch (e) {
            op = [6, e]
            y = 0
          } finally {
            f = t = 0
          }
        if (op[0] & 5) throw op[1]
        return {
          value: op[0] ? op[1] : void 0,
          done: true,
        }
      }
    }
    var __createBinding = Object.create
      ? function (o, m, k, k2) {
          if (k2 === undefined) k2 = k
          var desc = Object.getOwnPropertyDescriptor(m, k)
          if (
            !desc ||
            ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)
          ) {
            desc = {
              enumerable: true,
              get: function () {
                return m[k]
              },
            }
          }
          Object.defineProperty(o, k2, desc)
        }
      : function (o, m, k, k2) {
          if (k2 === undefined) k2 = k
          o[k2] = m[k]
        }
    function __exportStar(m, o) {
      for (var p in m)
        if (p !== "default" && !Object.prototype.hasOwnProperty.call(o, p))
          __createBinding(o, m, p)
    }
    function __values(o) {
      var s = typeof Symbol === "function" && Symbol.iterator,
        m = s && o[s],
        i = 0
      if (m) return m.call(o)
      if (o && typeof o.length === "number")
        return {
          next: function () {
            if (o && i >= o.length) o = void 0
            return {
              value: o && o[i++],
              done: !o,
            }
          },
        }
      throw new TypeError(
        s ? "Object is not iterable." : "Symbol.iterator is not defined.",
      )
    }
    function __read(o, n) {
      var m = typeof Symbol === "function" && o[Symbol.iterator]
      if (!m) return o
      var i = m.call(o),
        r,
        ar = [],
        e
      try {
        while ((n === void 0 || n-- > 0) && !(r = i.next()).done)
          ar.push(r.value)
      } catch (error) {
        e = {
          error: error,
        }
      } finally {
        try {
          if (r && !r.done && (m = i["return"])) m.call(i)
        } finally {
          if (e) throw e.error
        }
      }
      return ar
    }

    /** @deprecated */
    function __spread() {
      for (var ar = [], i = 0; i < arguments.length; i++)
        ar = ar.concat(__read(arguments[i]))
      return ar
    }

    /** @deprecated */
    function __spreadArrays() {
      for (var s = 0, i = 0, il = arguments.length; i < il; i++)
        s += arguments[i].length
      for (var r = Array(s), k = 0, i = 0; i < il; i++)
        for (var a = arguments[i], j = 0, jl = a.length; j < jl; j++, k++)
          r[k] = a[j]
      return r
    }
    function __spreadArray(to, from, pack) {
      if (pack || arguments.length === 2)
        for (var i = 0, l = from.length, ar; i < l; i++) {
          if (ar || !(i in from)) {
            if (!ar) ar = Array.prototype.slice.call(from, 0, i)
            ar[i] = from[i]
          }
        }
      return to.concat(ar || Array.prototype.slice.call(from))
    }
    function __await(v) {
      return this instanceof __await ? ((this.v = v), this) : new __await(v)
    }
    function __asyncGenerator(thisArg, _arguments, generator) {
      if (!Symbol.asyncIterator)
        throw new TypeError("Symbol.asyncIterator is not defined.")
      var g = generator.apply(thisArg, _arguments || []),
        i,
        q = []
      return (
        (i = {}),
        verb("next"),
        verb("throw"),
        verb("return"),
        (i[Symbol.asyncIterator] = function () {
          return this
        }),
        i
      )
      function verb(n) {
        if (g[n])
          i[n] = function (v) {
            return new Promise(function (a, b) {
              q.push([n, v, a, b]) > 1 || resume(n, v)
            })
          }
      }
      function resume(n, v) {
        try {
          step(g[n](v))
        } catch (e) {
          settle(q[0][3], e)
        }
      }
      function step(r) {
        r.value instanceof __await
          ? Promise.resolve(r.value.v).then(fulfill, reject)
          : settle(q[0][2], r)
      }
      function fulfill(value) {
        resume("next", value)
      }
      function reject(value) {
        resume("throw", value)
      }
      function settle(f, v) {
        if ((f(v), q.shift(), q.length)) resume(q[0][0], q[0][1])
      }
    }
    function __asyncDelegator(o) {
      var i, p
      return (
        (i = {}),
        verb("next"),
        verb("throw", function (e) {
          throw e
        }),
        verb("return"),
        (i[Symbol.iterator] = function () {
          return this
        }),
        i
      )
      function verb(n, f) {
        i[n] = o[n]
          ? function (v) {
              return (p = !p)
                ? {
                    value: __await(o[n](v)),
                    done: false,
                  }
                : f
                  ? f(v)
                  : v
            }
          : f
      }
    }
    function __asyncValues(o) {
      if (!Symbol.asyncIterator)
        throw new TypeError("Symbol.asyncIterator is not defined.")
      var m = o[Symbol.asyncIterator],
        i
      return m
        ? m.call(o)
        : ((o =
            typeof __values === "function"
              ? __values(o)
              : o[Symbol.iterator]()),
          (i = {}),
          verb("next"),
          verb("throw"),
          verb("return"),
          (i[Symbol.asyncIterator] = function () {
            return this
          }),
          i)
      function verb(n) {
        i[n] =
          o[n] &&
          function (v) {
            return new Promise(function (resolve, reject) {
              ;(v = o[n](v)), settle(resolve, reject, v.done, v.value)
            })
          }
      }
      function settle(resolve, reject, d, v) {
        Promise.resolve(v).then(function (v) {
          resolve({
            value: v,
            done: d,
          })
        }, reject)
      }
    }
    function __makeTemplateObject(cooked, raw) {
      if (Object.defineProperty) {
        Object.defineProperty(cooked, "raw", {
          value: raw,
        })
      } else {
        cooked.raw = raw
      }
      return cooked
    }
    var __setModuleDefault = Object.create
      ? function (o, v) {
          Object.defineProperty(o, "default", {
            enumerable: true,
            value: v,
          })
        }
      : function (o, v) {
          o["default"] = v
        }
    function __importStar(mod) {
      if (mod && mod.__esModule) return mod
      var result = {}
      if (mod != null)
        for (var k in mod)
          if (k !== "default" && Object.prototype.hasOwnProperty.call(mod, k))
            __createBinding(result, mod, k)
      __setModuleDefault(result, mod)
      return result
    }
    function __importDefault(mod) {
      return mod && mod.__esModule
        ? mod
        : {
            default: mod,
          }
    }
    function __classPrivateFieldGet(receiver, state, kind, f) {
      if (kind === "a" && !f)
        throw new TypeError("Private accessor was defined without a getter")
      if (
        typeof state === "function"
          ? receiver !== state || !f
          : !state.has(receiver)
      )
        throw new TypeError(
          "Cannot read private member from an object whose class did not declare it",
        )
      return kind === "m"
        ? f
        : kind === "a"
          ? f.call(receiver)
          : f
            ? f.value
            : state.get(receiver)
    }
    function __classPrivateFieldSet(receiver, state, value, kind, f) {
      if (kind === "m") throw new TypeError("Private method is not writable")
      if (kind === "a" && !f)
        throw new TypeError("Private accessor was defined without a setter")
      if (
        typeof state === "function"
          ? receiver !== state || !f
          : !state.has(receiver)
      )
        throw new TypeError(
          "Cannot write private member to an object whose class did not declare it",
        )
      return (
        kind === "a"
          ? f.call(receiver, value)
          : f
            ? (f.value = value)
            : state.set(receiver, value),
        value
      )
    }
    function __classPrivateFieldIn(state, receiver) {
      if (
        receiver === null ||
        (typeof receiver !== "object" && typeof receiver !== "function")
      )
        throw new TypeError("Cannot use 'in' operator on non-object")
      return typeof state === "function"
        ? receiver === state
        : state.has(receiver)
    } // CONCATENATED MODULE: ../../node_modules/rxjs/dist/esm5/internal/util/isArrayLike.js
    var isArrayLike = function (x) {
      return x && typeof x.length === "number" && typeof x !== "function"
    } // CONCATENATED MODULE: ../../node_modules/rxjs/dist/esm5/internal/util/isPromise.js
    function isPromise(value) {
      return isFunction_isFunction(
        value === null || value === void 0 ? void 0 : value.then,
      )
    } // CONCATENATED MODULE: ../../node_modules/rxjs/dist/esm5/internal/util/createErrorClass.js
    function createErrorClass(createImpl) {
      var _super = function (instance) {
        Error.call(instance)
        instance.stack = new Error().stack
      }
      var ctorFunc = createImpl(_super)
      ctorFunc.prototype = Object.create(Error.prototype)
      ctorFunc.prototype.constructor = ctorFunc
      return ctorFunc
    } // CONCATENATED MODULE: ../../node_modules/rxjs/dist/esm5/internal/util/UnsubscriptionError.js
    var UnsubscriptionError = createErrorClass(function (_super) {
      return function UnsubscriptionErrorImpl(errors) {
        _super(this)
        this.message = errors
          ? errors.length +
            " errors occurred during unsubscription:\n" +
            errors
              .map(function (err, i) {
                return i + 1 + ") " + err.toString()
              })
              .join("\n  ")
          : ""
        this.name = "UnsubscriptionError"
        this.errors = errors
      }
    }) // CONCATENATED MODULE: ../../node_modules/rxjs/dist/esm5/internal/util/arrRemove.js
    function arrRemove(arr, item) {
      if (arr) {
        var index = arr.indexOf(item)
        0 <= index && arr.splice(index, 1)
      }
    } // CONCATENATED MODULE: ../../node_modules/rxjs/dist/esm5/internal/Subscription.js
    var Subscription = (function () {
      function Subscription(initialTeardown) {
        this.initialTeardown = initialTeardown
        this.closed = false
        this._parentage = null
        this._finalizers = null
      }
      Subscription.prototype.unsubscribe = function () {
        var e_1, _a, e_2, _b
        var errors
        if (!this.closed) {
          this.closed = true
          var _parentage = this._parentage
          if (_parentage) {
            this._parentage = null
            if (Array.isArray(_parentage)) {
              try {
                for (
                  var _parentage_1 = __values(_parentage),
                    _parentage_1_1 = _parentage_1.next();
                  !_parentage_1_1.done;
                  _parentage_1_1 = _parentage_1.next()
                ) {
                  var parent_1 = _parentage_1_1.value
                  parent_1.remove(this)
                }
              } catch (e_1_1) {
                e_1 = {
                  error: e_1_1,
                }
              } finally {
                try {
                  if (
                    _parentage_1_1 &&
                    !_parentage_1_1.done &&
                    (_a = _parentage_1.return)
                  )
                    _a.call(_parentage_1)
                } finally {
                  if (e_1) throw e_1.error
                }
              }
            } else {
              _parentage.remove(this)
            }
          }
          var initialFinalizer = this.initialTeardown
          if (isFunction_isFunction(initialFinalizer)) {
            try {
              initialFinalizer()
            } catch (e) {
              errors = e instanceof UnsubscriptionError ? e.errors : [e]
            }
          }
          var _finalizers = this._finalizers
          if (_finalizers) {
            this._finalizers = null
            try {
              for (
                var _finalizers_1 = __values(_finalizers),
                  _finalizers_1_1 = _finalizers_1.next();
                !_finalizers_1_1.done;
                _finalizers_1_1 = _finalizers_1.next()
              ) {
                var finalizer = _finalizers_1_1.value
                try {
                  execFinalizer(finalizer)
                } catch (err) {
                  errors = errors !== null && errors !== void 0 ? errors : []
                  if (err instanceof UnsubscriptionError) {
                    errors = __spreadArray(
                      __spreadArray([], __read(errors)),
                      __read(err.errors),
                    )
                  } else {
                    errors.push(err)
                  }
                }
              }
            } catch (e_2_1) {
              e_2 = {
                error: e_2_1,
              }
            } finally {
              try {
                if (
                  _finalizers_1_1 &&
                  !_finalizers_1_1.done &&
                  (_b = _finalizers_1.return)
                )
                  _b.call(_finalizers_1)
              } finally {
                if (e_2) throw e_2.error
              }
            }
          }
          if (errors) {
            throw new UnsubscriptionError(errors)
          }
        }
      }
      Subscription.prototype.add = function (teardown) {
        var _a
        if (teardown && teardown !== this) {
          if (this.closed) {
            execFinalizer(teardown)
          } else {
            if (teardown instanceof Subscription) {
              if (teardown.closed || teardown._hasParent(this)) {
                return
              }
              teardown._addParent(this)
            }
            ;(this._finalizers =
              (_a = this._finalizers) !== null && _a !== void 0 ? _a : []).push(
              teardown,
            )
          }
        }
      }
      Subscription.prototype._hasParent = function (parent) {
        var _parentage = this._parentage
        return (
          _parentage === parent ||
          (Array.isArray(_parentage) && _parentage.includes(parent))
        )
      }
      Subscription.prototype._addParent = function (parent) {
        var _parentage = this._parentage
        this._parentage = Array.isArray(_parentage)
          ? (_parentage.push(parent), _parentage)
          : _parentage
            ? [_parentage, parent]
            : parent
      }
      Subscription.prototype._removeParent = function (parent) {
        var _parentage = this._parentage
        if (_parentage === parent) {
          this._parentage = null
        } else if (Array.isArray(_parentage)) {
          arrRemove(_parentage, parent)
        }
      }
      Subscription.prototype.remove = function (teardown) {
        var _finalizers = this._finalizers
        _finalizers && arrRemove(_finalizers, teardown)
        if (teardown instanceof Subscription) {
          teardown._removeParent(this)
        }
      }
      Subscription.EMPTY = (function () {
        var empty = new Subscription()
        empty.closed = true
        return empty
      })()
      return Subscription
    })()

    var EMPTY_SUBSCRIPTION = Subscription.EMPTY
    function isSubscription(value) {
      return (
        value instanceof Subscription ||
        (value &&
          "closed" in value &&
          isFunction_isFunction(value.remove) &&
          isFunction_isFunction(value.add) &&
          isFunction_isFunction(value.unsubscribe))
      )
    }
    function execFinalizer(finalizer) {
      if (isFunction_isFunction(finalizer)) {
        finalizer()
      } else {
        finalizer.unsubscribe()
      }
    } // CONCATENATED MODULE: ../../node_modules/rxjs/dist/esm5/internal/config.js
    var config = {
      onUnhandledError: null,
      onStoppedNotification: null,
      Promise: undefined,
      useDeprecatedSynchronousErrorHandling: false,
      useDeprecatedNextContext: false,
    } // CONCATENATED MODULE: ../../node_modules/rxjs/dist/esm5/internal/scheduler/timeoutProvider.js
    var timeoutProvider = {
      setTimeout: function (handler, timeout) {
        var args = []
        for (var _i = 2; _i < arguments.length; _i++) {
          args[_i - 2] = arguments[_i]
        }
        var delegate = timeoutProvider.delegate
        if (
          delegate === null || delegate === void 0
            ? void 0
            : delegate.setTimeout
        ) {
          return delegate.setTimeout.apply(
            delegate,
            __spreadArray([handler, timeout], __read(args)),
          )
        }
        return setTimeout.apply(
          void 0,
          __spreadArray([handler, timeout], __read(args)),
        )
      },
      clearTimeout: function (handle) {
        var delegate = timeoutProvider.delegate
        return (
          (delegate === null || delegate === void 0
            ? void 0
            : delegate.clearTimeout) || clearTimeout
        )(handle)
      },
      delegate: undefined,
    } // CONCATENATED MODULE: ../../node_modules/rxjs/dist/esm5/internal/util/reportUnhandledError.js
    function reportUnhandledError(err) {
      timeoutProvider.setTimeout(function () {
        var onUnhandledError = config.onUnhandledError
        if (onUnhandledError) {
          onUnhandledError(err)
        } else {
          throw err
        }
      })
    } // CONCATENATED MODULE: ../../node_modules/rxjs/dist/esm5/internal/util/noop.js
    function noop() {} // CONCATENATED MODULE: ../../node_modules/rxjs/dist/esm5/internal/NotificationFactories.js
    var COMPLETE_NOTIFICATION = (function () {
      return createNotification("C", undefined, undefined)
    })()
    function errorNotification(error) {
      return createNotification("E", undefined, error)
    }
    function nextNotification(value) {
      return createNotification("N", value, undefined)
    }
    function createNotification(kind, value, error) {
      return {
        kind: kind,
        value: value,
        error: error,
      }
    } // CONCATENATED MODULE: ../../node_modules/rxjs/dist/esm5/internal/util/errorContext.js
    var context = null
    function errorContext(cb) {
      if (config.useDeprecatedSynchronousErrorHandling) {
        var isRoot = !context
        if (isRoot) {
          context = {
            errorThrown: false,
            error: null,
          }
        }
        cb()
        if (isRoot) {
          var _a = context,
            errorThrown = _a.errorThrown,
            error = _a.error
          context = null
          if (errorThrown) {
            throw error
          }
        }
      } else {
        cb()
      }
    }
    function captureError(err) {
      if (config.useDeprecatedSynchronousErrorHandling && context) {
        context.errorThrown = true
        context.error = err
      }
    } // CONCATENATED MODULE: ../../node_modules/rxjs/dist/esm5/internal/Subscriber.js
    var Subscriber = (function (_super) {
      __extends(Subscriber, _super)
      function Subscriber(destination) {
        var _this = _super.call(this) || this
        _this.isStopped = false
        if (destination) {
          _this.destination = destination
          if (isSubscription(destination)) {
            destination.add(_this)
          }
        } else {
          _this.destination = EMPTY_OBSERVER
        }
        return _this
      }
      Subscriber.create = function (next, error, complete) {
        return new SafeSubscriber(next, error, complete)
      }
      Subscriber.prototype.next = function (value) {
        if (this.isStopped) {
          handleStoppedNotification(nextNotification(value), this)
        } else {
          this._next(value)
        }
      }
      Subscriber.prototype.error = function (err) {
        if (this.isStopped) {
          handleStoppedNotification(errorNotification(err), this)
        } else {
          this.isStopped = true
          this._error(err)
        }
      }
      Subscriber.prototype.complete = function () {
        if (this.isStopped) {
          handleStoppedNotification(COMPLETE_NOTIFICATION, this)
        } else {
          this.isStopped = true
          this._complete()
        }
      }
      Subscriber.prototype.unsubscribe = function () {
        if (!this.closed) {
          this.isStopped = true
          _super.prototype.unsubscribe.call(this)
          this.destination = null
        }
      }
      Subscriber.prototype._next = function (value) {
        this.destination.next(value)
      }
      Subscriber.prototype._error = function (err) {
        try {
          this.destination.error(err)
        } finally {
          this.unsubscribe()
        }
      }
      Subscriber.prototype._complete = function () {
        try {
          this.destination.complete()
        } finally {
          this.unsubscribe()
        }
      }
      return Subscriber
    })(Subscription)

    var _bind = Function.prototype.bind
    function bind(fn, thisArg) {
      return _bind.call(fn, thisArg)
    }
    var ConsumerObserver = (function () {
      function ConsumerObserver(partialObserver) {
        this.partialObserver = partialObserver
      }
      ConsumerObserver.prototype.next = function (value) {
        var partialObserver = this.partialObserver
        if (partialObserver.next) {
          try {
            partialObserver.next(value)
          } catch (error) {
            handleUnhandledError(error)
          }
        }
      }
      ConsumerObserver.prototype.error = function (err) {
        var partialObserver = this.partialObserver
        if (partialObserver.error) {
          try {
            partialObserver.error(err)
          } catch (error) {
            handleUnhandledError(error)
          }
        } else {
          handleUnhandledError(err)
        }
      }
      ConsumerObserver.prototype.complete = function () {
        var partialObserver = this.partialObserver
        if (partialObserver.complete) {
          try {
            partialObserver.complete()
          } catch (error) {
            handleUnhandledError(error)
          }
        }
      }
      return ConsumerObserver
    })()
    var SafeSubscriber = (function (_super) {
      __extends(SafeSubscriber, _super)
      function SafeSubscriber(observerOrNext, error, complete) {
        var _this = _super.call(this) || this
        var partialObserver
        if (isFunction_isFunction(observerOrNext) || !observerOrNext) {
          partialObserver = {
            next:
              observerOrNext !== null && observerOrNext !== void 0
                ? observerOrNext
                : undefined,
            error: error !== null && error !== void 0 ? error : undefined,
            complete:
              complete !== null && complete !== void 0 ? complete : undefined,
          }
        } else {
          var context_1
          if (_this && config.useDeprecatedNextContext) {
            context_1 = Object.create(observerOrNext)
            context_1.unsubscribe = function () {
              return _this.unsubscribe()
            }
            partialObserver = {
              next: observerOrNext.next && bind(observerOrNext.next, context_1),
              error:
                observerOrNext.error && bind(observerOrNext.error, context_1),
              complete:
                observerOrNext.complete &&
                bind(observerOrNext.complete, context_1),
            }
          } else {
            partialObserver = observerOrNext
          }
        }
        _this.destination = new ConsumerObserver(partialObserver)
        return _this
      }
      return SafeSubscriber
    })(Subscriber)

    function handleUnhandledError(error) {
      if (config.useDeprecatedSynchronousErrorHandling) {
        captureError(error)
      } else {
        reportUnhandledError(error)
      }
    }
    function defaultErrorHandler(err) {
      throw err
    }
    function handleStoppedNotification(notification, subscriber) {
      var onStoppedNotification = config.onStoppedNotification
      onStoppedNotification &&
        timeoutProvider.setTimeout(function () {
          return onStoppedNotification(notification, subscriber)
        })
    }
    var EMPTY_OBSERVER = {
      closed: true,
      next: noop,
      error: defaultErrorHandler,
      complete: noop,
    } // CONCATENATED MODULE: ../../node_modules/rxjs/dist/esm5/internal/symbol/observable.js
    var observable = (function () {
      return (
        (typeof Symbol === "function" && Symbol.observable) || "@@observable"
      )
    })() // CONCATENATED MODULE: ../../node_modules/rxjs/dist/esm5/internal/util/identity.js
    function identity(x) {
      return x
    } // CONCATENATED MODULE: ../../node_modules/rxjs/dist/esm5/internal/util/pipe.js
    function pipe() {
      var fns = []
      for (var _i = 0; _i < arguments.length; _i++) {
        fns[_i] = arguments[_i]
      }
      return pipeFromArray(fns)
    }
    function pipeFromArray(fns) {
      if (fns.length === 0) {
        return identity
      }
      if (fns.length === 1) {
        return fns[0]
      }
      return function piped(input) {
        return fns.reduce(function (prev, fn) {
          return fn(prev)
        }, input)
      }
    } // CONCATENATED MODULE: ../../node_modules/rxjs/dist/esm5/internal/Observable.js
    var Observable = (function () {
      function Observable(subscribe) {
        if (subscribe) {
          this._subscribe = subscribe
        }
      }
      Observable.prototype.lift = function (operator) {
        var observable = new Observable()
        observable.source = this
        observable.operator = operator
        return observable
      }
      Observable.prototype.subscribe = function (
        observerOrNext,
        error,
        complete,
      ) {
        var _this = this
        var subscriber = isSubscriber(observerOrNext)
          ? observerOrNext
          : new SafeSubscriber(observerOrNext, error, complete)
        errorContext(function () {
          var _a = _this,
            operator = _a.operator,
            source = _a.source
          subscriber.add(
            operator
              ? operator.call(subscriber, source)
              : source
                ? _this._subscribe(subscriber)
                : _this._trySubscribe(subscriber),
          )
        })
        return subscriber
      }
      Observable.prototype._trySubscribe = function (sink) {
        try {
          return this._subscribe(sink)
        } catch (err) {
          sink.error(err)
        }
      }
      Observable.prototype.forEach = function (next, promiseCtor) {
        var _this = this
        promiseCtor = getPromiseCtor(promiseCtor)
        return new promiseCtor(function (resolve, reject) {
          var subscriber = new SafeSubscriber({
            next: function (value) {
              try {
                next(value)
              } catch (err) {
                reject(err)
                subscriber.unsubscribe()
              }
            },
            error: reject,
            complete: resolve,
          })
          _this.subscribe(subscriber)
        })
      }
      Observable.prototype._subscribe = function (subscriber) {
        var _a
        return (_a = this.source) === null || _a === void 0
          ? void 0
          : _a.subscribe(subscriber)
      }
      Observable.prototype[observable] = function () {
        return this
      }
      Observable.prototype.pipe = function () {
        var operations = []
        for (var _i = 0; _i < arguments.length; _i++) {
          operations[_i] = arguments[_i]
        }
        return pipeFromArray(operations)(this)
      }
      Observable.prototype.toPromise = function (promiseCtor) {
        var _this = this
        promiseCtor = getPromiseCtor(promiseCtor)
        return new promiseCtor(function (resolve, reject) {
          var value
          _this.subscribe(
            function (x) {
              return (value = x)
            },
            function (err) {
              return reject(err)
            },
            function () {
              return resolve(value)
            },
          )
        })
      }
      Observable.create = function (subscribe) {
        return new Observable(subscribe)
      }
      return Observable
    })()

    function getPromiseCtor(promiseCtor) {
      var _a
      return (_a =
        promiseCtor !== null && promiseCtor !== void 0
          ? promiseCtor
          : config.Promise) !== null && _a !== void 0
        ? _a
        : Promise
    }
    function isObserver(value) {
      return (
        value &&
        isFunction_isFunction(value.next) &&
        isFunction_isFunction(value.error) &&
        isFunction_isFunction(value.complete)
      )
    }
    function isSubscriber(value) {
      return (
        (value && value instanceof Subscriber) ||
        (isObserver(value) && isSubscription(value))
      )
    } // CONCATENATED MODULE: ../../node_modules/rxjs/dist/esm5/internal/util/isInteropObservable.js
    function isInteropObservable(input) {
      return isFunction_isFunction(input[observable])
    } // CONCATENATED MODULE: ../../node_modules/rxjs/dist/esm5/internal/util/isAsyncIterable.js
    function isAsyncIterable(obj) {
      return (
        Symbol.asyncIterator &&
        isFunction_isFunction(
          obj === null || obj === void 0 ? void 0 : obj[Symbol.asyncIterator],
        )
      )
    } // CONCATENATED MODULE: ../../node_modules/rxjs/dist/esm5/internal/util/throwUnobservableError.js
    function createInvalidObservableTypeError(input) {
      return new TypeError(
        "You provided " +
          (input !== null && typeof input === "object"
            ? "an invalid object"
            : "'" + input + "'") +
          " where a stream was expected. You can provide an Observable, Promise, ReadableStream, Array, AsyncIterable, or Iterable.",
      )
    } // CONCATENATED MODULE: ../../node_modules/rxjs/dist/esm5/internal/symbol/iterator.js
    function getSymbolIterator() {
      if (typeof Symbol !== "function" || !Symbol.iterator) {
        return "@@iterator"
      }
      return Symbol.iterator
    }
    var iterator_iterator = getSymbolIterator() // CONCATENATED MODULE: ../../node_modules/rxjs/dist/esm5/internal/util/isIterable.js
    function isIterable(input) {
      return isFunction_isFunction(
        input === null || input === void 0 ? void 0 : input[iterator_iterator],
      )
    } // CONCATENATED MODULE: ../../node_modules/rxjs/dist/esm5/internal/util/isReadableStreamLike.js
    function readableStreamLikeToAsyncGenerator(readableStream) {
      return __asyncGenerator(
        this,
        arguments,
        function readableStreamLikeToAsyncGenerator_1() {
          var reader, _a, value, done
          return __generator(this, function (_b) {
            switch (_b.label) {
              case 0:
                reader = readableStream.getReader()
                _b.label = 1
              case 1:
                _b.trys.push([1, , 9, 10])
                _b.label = 2
              case 2:
                if (false) {
                }
                return [4, __await(reader.read())]
              case 3:
                ;(_a = _b.sent()), (value = _a.value), (done = _a.done)
                if (!done) return [3, 5]
                return [4, __await(void 0)]
              case 4:
                return [2, _b.sent()]
              case 5:
                return [4, __await(value)]
              case 6:
                return [4, _b.sent()]
              case 7:
                _b.sent()
                return [3, 2]
              case 8:
                return [3, 10]
              case 9:
                reader.releaseLock()
                return [7]
              case 10:
                return [2]
            }
          })
        },
      )
    }
    function isReadableStreamLike(obj) {
      return isFunction_isFunction(
        obj === null || obj === void 0 ? void 0 : obj.getReader,
      )
    } // CONCATENATED MODULE: ../../node_modules/rxjs/dist/esm5/internal/observable/innerFrom.js
    function innerFrom(input) {
      if (input instanceof Observable) {
        return input
      }
      if (input != null) {
        if (isInteropObservable(input)) {
          return fromInteropObservable(input)
        }
        if (isArrayLike(input)) {
          return fromArrayLike(input)
        }
        if (isPromise(input)) {
          return fromPromise(input)
        }
        if (isAsyncIterable(input)) {
          return fromAsyncIterable(input)
        }
        if (isIterable(input)) {
          return fromIterable(input)
        }
        if (isReadableStreamLike(input)) {
          return fromReadableStreamLike(input)
        }
      }
      throw createInvalidObservableTypeError(input)
    }
    function fromInteropObservable(obj) {
      return new Observable(function (subscriber) {
        var obs = obj[observable]()
        if (isFunction_isFunction(obs.subscribe)) {
          return obs.subscribe(subscriber)
        }
        throw new TypeError(
          "Provided object does not correctly implement Symbol.observable",
        )
      })
    }
    function fromArrayLike(array) {
      return new Observable(function (subscriber) {
        for (var i = 0; i < array.length && !subscriber.closed; i++) {
          subscriber.next(array[i])
        }
        subscriber.complete()
      })
    }
    function fromPromise(promise) {
      return new Observable(function (subscriber) {
        promise
          .then(
            function (value) {
              if (!subscriber.closed) {
                subscriber.next(value)
                subscriber.complete()
              }
            },
            function (err) {
              return subscriber.error(err)
            },
          )
          .then(null, reportUnhandledError)
      })
    }
    function fromIterable(iterable) {
      return new Observable(function (subscriber) {
        var e_1, _a
        try {
          for (
            var iterable_1 = __values(iterable),
              iterable_1_1 = iterable_1.next();
            !iterable_1_1.done;
            iterable_1_1 = iterable_1.next()
          ) {
            var value = iterable_1_1.value
            subscriber.next(value)
            if (subscriber.closed) {
              return
            }
          }
        } catch (e_1_1) {
          e_1 = {
            error: e_1_1,
          }
        } finally {
          try {
            if (iterable_1_1 && !iterable_1_1.done && (_a = iterable_1.return))
              _a.call(iterable_1)
          } finally {
            if (e_1) throw e_1.error
          }
        }
        subscriber.complete()
      })
    }
    function fromAsyncIterable(asyncIterable) {
      return new Observable(function (subscriber) {
        process(asyncIterable, subscriber).catch(function (err) {
          return subscriber.error(err)
        })
      })
    }
    function fromReadableStreamLike(readableStream) {
      return fromAsyncIterable(
        readableStreamLikeToAsyncGenerator(readableStream),
      )
    }
    function process(asyncIterable, subscriber) {
      var asyncIterable_1, asyncIterable_1_1
      var e_2, _a
      return __awaiter(this, void 0, void 0, function () {
        var value, e_2_1
        return __generator(this, function (_b) {
          switch (_b.label) {
            case 0:
              _b.trys.push([0, 5, 6, 11])
              asyncIterable_1 = __asyncValues(asyncIterable)
              _b.label = 1
            case 1:
              return [4, asyncIterable_1.next()]
            case 2:
              if (!((asyncIterable_1_1 = _b.sent()), !asyncIterable_1_1.done))
                return [3, 4]
              value = asyncIterable_1_1.value
              subscriber.next(value)
              if (subscriber.closed) {
                return [2]
              }
              _b.label = 3
            case 3:
              return [3, 1]
            case 4:
              return [3, 11]
            case 5:
              e_2_1 = _b.sent()
              e_2 = {
                error: e_2_1,
              }
              return [3, 11]
            case 6:
              _b.trys.push([6, , 9, 10])
              if (
                !(
                  asyncIterable_1_1 &&
                  !asyncIterable_1_1.done &&
                  (_a = asyncIterable_1.return)
                )
              )
                return [3, 8]
              return [4, _a.call(asyncIterable_1)]
            case 7:
              _b.sent()
              _b.label = 8
            case 8:
              return [3, 10]
            case 9:
              if (e_2) throw e_2.error
              return [7]
            case 10:
              return [7]
            case 11:
              subscriber.complete()
              return [2]
          }
        })
      })
    } // CONCATENATED MODULE: ../../node_modules/rxjs/dist/esm5/internal/util/executeSchedule.js
    function executeSchedule(
      parentSubscription,
      scheduler,
      work,
      delay,
      repeat,
    ) {
      if (delay === void 0) {
        delay = 0
      }
      if (repeat === void 0) {
        repeat = false
      }
      var scheduleSubscription = scheduler.schedule(function () {
        work()
        if (repeat) {
          parentSubscription.add(this.schedule(null, delay))
        } else {
          this.unsubscribe()
        }
      }, delay)
      parentSubscription.add(scheduleSubscription)
      if (!repeat) {
        return scheduleSubscription
      }
    } // CONCATENATED MODULE: ../../node_modules/rxjs/dist/esm5/internal/util/lift.js
    function hasLift(source) {
      return isFunction_isFunction(
        source === null || source === void 0 ? void 0 : source.lift,
      )
    }
    function operate(init) {
      return function (source) {
        if (hasLift(source)) {
          return source.lift(function (liftedSource) {
            try {
              return init(liftedSource, this)
            } catch (err) {
              this.error(err)
            }
          })
        }
        throw new TypeError("Unable to lift unknown Observable type")
      }
    } // CONCATENATED MODULE: ../../node_modules/rxjs/dist/esm5/internal/operators/OperatorSubscriber.js
    function createOperatorSubscriber(
      destination,
      onNext,
      onComplete,
      onError,
      onFinalize,
    ) {
      return new OperatorSubscriber(
        destination,
        onNext,
        onComplete,
        onError,
        onFinalize,
      )
    }
    var OperatorSubscriber = (function (_super) {
      __extends(OperatorSubscriber, _super)
      function OperatorSubscriber(
        destination,
        onNext,
        onComplete,
        onError,
        onFinalize,
        shouldUnsubscribe,
      ) {
        var _this = _super.call(this, destination) || this
        _this.onFinalize = onFinalize
        _this.shouldUnsubscribe = shouldUnsubscribe
        _this._next = onNext
          ? function (value) {
              try {
                onNext(value)
              } catch (err) {
                destination.error(err)
              }
            }
          : _super.prototype._next
        _this._error = onError
          ? function (err) {
              try {
                onError(err)
              } catch (err) {
                destination.error(err)
              } finally {
                this.unsubscribe()
              }
            }
          : _super.prototype._error
        _this._complete = onComplete
          ? function () {
              try {
                onComplete()
              } catch (err) {
                destination.error(err)
              } finally {
                this.unsubscribe()
              }
            }
          : _super.prototype._complete
        return _this
      }
      OperatorSubscriber.prototype.unsubscribe = function () {
        var _a
        if (!this.shouldUnsubscribe || this.shouldUnsubscribe()) {
          var closed_1 = this.closed
          _super.prototype.unsubscribe.call(this)
          !closed_1 &&
            ((_a = this.onFinalize) === null || _a === void 0
              ? void 0
              : _a.call(this))
        }
      }
      return OperatorSubscriber
    })(Subscriber) // CONCATENATED MODULE: ../../node_modules/rxjs/dist/esm5/internal/operators/observeOn.js

    function observeOn(scheduler, delay) {
      if (delay === void 0) {
        delay = 0
      }
      return operate(function (source, subscriber) {
        source.subscribe(
          createOperatorSubscriber(
            subscriber,
            function (value) {
              return executeSchedule(
                subscriber,
                scheduler,
                function () {
                  return subscriber.next(value)
                },
                delay,
              )
            },
            function () {
              return executeSchedule(
                subscriber,
                scheduler,
                function () {
                  return subscriber.complete()
                },
                delay,
              )
            },
            function (err) {
              return executeSchedule(
                subscriber,
                scheduler,
                function () {
                  return subscriber.error(err)
                },
                delay,
              )
            },
          ),
        )
      })
    } // CONCATENATED MODULE: ../../node_modules/rxjs/dist/esm5/internal/operators/subscribeOn.js
    function subscribeOn(scheduler, delay) {
      if (delay === void 0) {
        delay = 0
      }
      return operate(function (source, subscriber) {
        subscriber.add(
          scheduler.schedule(function () {
            return source.subscribe(subscriber)
          }, delay),
        )
      })
    } // CONCATENATED MODULE: ../../node_modules/rxjs/dist/esm5/internal/scheduled/scheduleObservable.js
    function scheduleObservable(input, scheduler) {
      return innerFrom(input).pipe(subscribeOn(scheduler), observeOn(scheduler))
    } // CONCATENATED MODULE: ../../node_modules/rxjs/dist/esm5/internal/scheduled/schedulePromise.js
    function schedulePromise(input, scheduler) {
      return innerFrom(input).pipe(subscribeOn(scheduler), observeOn(scheduler))
    } // CONCATENATED MODULE: ../../node_modules/rxjs/dist/esm5/internal/scheduled/scheduleArray.js
    function scheduleArray(input, scheduler) {
      return new Observable(function (subscriber) {
        var i = 0
        return scheduler.schedule(function () {
          if (i === input.length) {
            subscriber.complete()
          } else {
            subscriber.next(input[i++])
            if (!subscriber.closed) {
              this.schedule()
            }
          }
        })
      })
    } // CONCATENATED MODULE: ../../node_modules/rxjs/dist/esm5/internal/scheduled/scheduleIterable.js
    function scheduleIterable(input, scheduler) {
      return new Observable(function (subscriber) {
        var iterator
        executeSchedule(subscriber, scheduler, function () {
          iterator = input[iterator_iterator]()
          executeSchedule(
            subscriber,
            scheduler,
            function () {
              var _a
              var value
              var done
              try {
                ;(_a = iterator.next()), (value = _a.value), (done = _a.done)
              } catch (err) {
                subscriber.error(err)
                return
              }
              if (done) {
                subscriber.complete()
              } else {
                subscriber.next(value)
              }
            },
            0,
            true,
          )
        })
        return function () {
          return (
            isFunction_isFunction(
              iterator === null || iterator === void 0
                ? void 0
                : iterator.return,
            ) && iterator.return()
          )
        }
      })
    } // CONCATENATED MODULE: ../../node_modules/rxjs/dist/esm5/internal/scheduled/scheduleAsyncIterable.js
    function scheduleAsyncIterable(input, scheduler) {
      if (!input) {
        throw new Error("Iterable cannot be null")
      }
      return new Observable(function (subscriber) {
        executeSchedule(subscriber, scheduler, function () {
          var iterator = input[Symbol.asyncIterator]()
          executeSchedule(
            subscriber,
            scheduler,
            function () {
              iterator.next().then(function (result) {
                if (result.done) {
                  subscriber.complete()
                } else {
                  subscriber.next(result.value)
                }
              })
            },
            0,
            true,
          )
        })
      })
    } // CONCATENATED MODULE: ../../node_modules/rxjs/dist/esm5/internal/scheduled/scheduleReadableStreamLike.js
    function scheduleReadableStreamLike(input, scheduler) {
      return scheduleAsyncIterable(
        readableStreamLikeToAsyncGenerator(input),
        scheduler,
      )
    } // CONCATENATED MODULE: ../../node_modules/rxjs/dist/esm5/internal/scheduled/scheduled.js
    function scheduled(input, scheduler) {
      if (input != null) {
        if (isInteropObservable(input)) {
          return scheduleObservable(input, scheduler)
        }
        if (isArrayLike(input)) {
          return scheduleArray(input, scheduler)
        }
        if (isPromise(input)) {
          return schedulePromise(input, scheduler)
        }
        if (isAsyncIterable(input)) {
          return scheduleAsyncIterable(input, scheduler)
        }
        if (isIterable(input)) {
          return scheduleIterable(input, scheduler)
        }
        if (isReadableStreamLike(input)) {
          return scheduleReadableStreamLike(input, scheduler)
        }
      }
      throw createInvalidObservableTypeError(input)
    } // CONCATENATED MODULE: ../../node_modules/rxjs/dist/esm5/internal/observable/from.js
    function from(input, scheduler) {
      return scheduler ? scheduled(input, scheduler) : innerFrom(input)
    } // CONCATENATED MODULE: ../../node_modules/rxjs/dist/esm5/internal/observable/of.js
    function of() {
      var args = []
      for (var _i = 0; _i < arguments.length; _i++) {
        args[_i] = arguments[_i]
      }
      var scheduler = popScheduler(args)
      return from(args, scheduler)
    } // CONCATENATED MODULE: ../../node_modules/rxjs/dist/esm5/internal/operators/switchMap.js
    function switchMap(project, resultSelector) {
      return operate(function (source, subscriber) {
        var innerSubscriber = null
        var index = 0
        var isComplete = false
        var checkComplete = function () {
          return isComplete && !innerSubscriber && subscriber.complete()
        }
        source.subscribe(
          createOperatorSubscriber(
            subscriber,
            function (value) {
              innerSubscriber === null || innerSubscriber === void 0
                ? void 0
                : innerSubscriber.unsubscribe()
              var innerIndex = 0
              var outerIndex = index++
              innerFrom(project(value, outerIndex)).subscribe(
                (innerSubscriber = createOperatorSubscriber(
                  subscriber,
                  function (innerValue) {
                    return subscriber.next(
                      resultSelector
                        ? resultSelector(
                            value,
                            innerValue,
                            outerIndex,
                            innerIndex++,
                          )
                        : innerValue,
                    )
                  },
                  function () {
                    innerSubscriber = null
                    checkComplete()
                  },
                )),
              )
            },
            function () {
              isComplete = true
              checkComplete()
            },
          ),
        )
      })
    } // CONCATENATED MODULE: ../../node_modules/tldts-core/dist/es6/src/domain.js
    /**
     * Check if `vhost` is a valid suffix of `hostname` (top-domain)
     *
     * It means that `vhost` needs to be a suffix of `hostname` and we then need to
     * make sure that: either they are equal, or the character preceding `vhost` in
     * `hostname` is a '.' (it should not be a partial label).
     *
     * * hostname = 'not.evil.com' and vhost = 'vil.com'      => not ok
     * * hostname = 'not.evil.com' and vhost = 'evil.com'     => ok
     * * hostname = 'not.evil.com' and vhost = 'not.evil.com' => ok
     */
    function shareSameDomainSuffix(hostname, vhost) {
      if (hostname.endsWith(vhost)) {
        return (
          hostname.length === vhost.length ||
          hostname[hostname.length - vhost.length - 1] === "."
        )
      }
      return false
    }
    /**
     * Given a hostname and its public suffix, extract the general domain.
     */
    function extractDomainWithSuffix(hostname, publicSuffix) {
      // Locate the index of the last '.' in the part of the `hostname` preceding
      // the public suffix.
      //
      // examples:
      //   1. not.evil.co.uk  => evil.co.uk
      //         ^    ^
      //         |    | start of public suffix
      //         | index of the last dot
      //
      //   2. example.co.uk   => example.co.uk
      //     ^       ^
      //     |       | start of public suffix
      //     |
      //     | (-1) no dot found before the public suffix
      const publicSuffixIndex = hostname.length - publicSuffix.length - 2
      const lastDotBeforeSuffixIndex = hostname.lastIndexOf(
        ".",
        publicSuffixIndex,
      )
      // No '.' found, then `hostname` is the general domain (no sub-domain)
      if (lastDotBeforeSuffixIndex === -1) {
        return hostname
      }
      // Extract the part between the last '.'
      return hostname.slice(lastDotBeforeSuffixIndex + 1)
    }
    /**
     * Detects the domain based on rules and upon and a host string
     */
    function getDomain(suffix, hostname, options) {
      // Check if `hostname` ends with a member of `validHosts`.
      if (options.validHosts !== null) {
        const validHosts = options.validHosts
        for (const vhost of validHosts) {
          if (/*@__INLINE__*/ shareSameDomainSuffix(hostname, vhost)) {
            return vhost
          }
        }
      }
      let numberOfLeadingDots = 0
      if (hostname.startsWith(".")) {
        while (
          numberOfLeadingDots < hostname.length &&
          hostname[numberOfLeadingDots] === "."
        ) {
          numberOfLeadingDots += 1
        }
      }
      // If `hostname` is a valid public suffix, then there is no domain to return.
      // Since we already know that `getPublicSuffix` returns a suffix of `hostname`
      // there is no need to perform a string comparison and we only compare the
      // size.
      if (suffix.length === hostname.length - numberOfLeadingDots) {
        return null
      }
      // To extract the general domain, we start by identifying the public suffix
      // (if any), then consider the domain to be the public suffix with one added
      // level of depth. (e.g.: if hostname is `not.evil.co.uk` and public suffix:
      // `co.uk`, then we take one more level: `evil`, giving the final result:
      // `evil.co.uk`).
      return /*@__INLINE__*/ extractDomainWithSuffix(hostname, suffix)
    } // CONCATENATED MODULE: ../../node_modules/tldts-core/dist/es6/src/domain-without-suffix.js
    /**
     * Return the part of domain without suffix.
     *
     * Example: for domain 'foo.com', the result would be 'foo'.
     */
    function getDomainWithoutSuffix(domain, suffix) {
      // Note: here `domain` and `suffix` cannot have the same length because in
      // this case we set `domain` to `null` instead. It is thus safe to assume
      // that `suffix` is shorter than `domain`.
      return domain.slice(0, -suffix.length - 1)
    } // CONCATENATED MODULE: ../../node_modules/tldts-core/dist/es6/src/extract-hostname.js
    /**
     * @param url - URL we want to extract a hostname from.
     * @param urlIsValidHostname - hint from caller; true if `url` is already a valid hostname.
     */
    function extractHostname(url, urlIsValidHostname) {
      let start = 0
      let end = url.length
      let hasUpper = false
      // If url is not already a valid hostname, then try to extract hostname.
      if (!urlIsValidHostname) {
        // Special handling of data URLs
        if (url.startsWith("data:")) {
          return null
        }
        // Trim leading spaces
        while (start < url.length && url.charCodeAt(start) <= 32) {
          start += 1
        }
        // Trim trailing spaces
        while (end > start + 1 && url.charCodeAt(end - 1) <= 32) {
          end -= 1
        }
        // Skip scheme.
        if (
          url.charCodeAt(start) === 47 /* '/' */ &&
          url.charCodeAt(start + 1) === 47 /* '/' */
        ) {
          start += 2
        } else {
          const indexOfProtocol = url.indexOf(":/", start)
          if (indexOfProtocol !== -1) {
            // Implement fast-path for common protocols. We expect most protocols
            // should be one of these 4 and thus we will not need to perform the
            // more expansive validity check most of the time.
            const protocolSize = indexOfProtocol - start
            const c0 = url.charCodeAt(start)
            const c1 = url.charCodeAt(start + 1)
            const c2 = url.charCodeAt(start + 2)
            const c3 = url.charCodeAt(start + 3)
            const c4 = url.charCodeAt(start + 4)
            if (
              protocolSize === 5 &&
              c0 === 104 /* 'h' */ &&
              c1 === 116 /* 't' */ &&
              c2 === 116 /* 't' */ &&
              c3 === 112 /* 'p' */ &&
              c4 === 115 /* 's' */
            ) {
              // https
            } else if (
              protocolSize === 4 &&
              c0 === 104 /* 'h' */ &&
              c1 === 116 /* 't' */ &&
              c2 === 116 /* 't' */ &&
              c3 === 112 /* 'p' */
            ) {
              // http
            } else if (
              protocolSize === 3 &&
              c0 === 119 /* 'w' */ &&
              c1 === 115 /* 's' */ &&
              c2 === 115 /* 's' */
            ) {
              // wss
            } else if (
              protocolSize === 2 &&
              c0 === 119 /* 'w' */ &&
              c1 === 115 /* 's' */
            ) {
              // ws
            } else {
              // Check that scheme is valid
              for (let i = start; i < indexOfProtocol; i += 1) {
                const lowerCaseCode = url.charCodeAt(i) | 32
                if (
                  !(
                    (
                      (lowerCaseCode >= 97 && lowerCaseCode <= 122) ||
                      // [a, z]
                      (lowerCaseCode >= 48 && lowerCaseCode <= 57) ||
                      // [0, 9]
                      lowerCaseCode === 46 ||
                      // '.'
                      lowerCaseCode === 45 ||
                      // '-'
                      lowerCaseCode === 43
                    ) // '+'
                  )
                ) {
                  return null
                }
              }
            }
            // Skip 0, 1 or more '/' after ':/'
            start = indexOfProtocol + 2
            while (url.charCodeAt(start) === 47 /* '/' */) {
              start += 1
            }
          }
        }
        // Detect first occurrence of '/', '?' or '#'. We also keep track of the
        // last occurrence of '@', ']' or ':' to speed-up subsequent parsing of
        // (respectively), identifier, ipv6 or port.
        let indexOfIdentifier = -1
        let indexOfClosingBracket = -1
        let indexOfPort = -1
        for (let i = start; i < end; i += 1) {
          const code = url.charCodeAt(i)
          if (
            code === 35 ||
            // '#'
            code === 47 ||
            // '/'
            code === 63 // '?'
          ) {
            end = i
            break
          } else if (code === 64) {
            // '@'
            indexOfIdentifier = i
          } else if (code === 93) {
            // ']'
            indexOfClosingBracket = i
          } else if (code === 58) {
            // ':'
            indexOfPort = i
          } else if (code >= 65 && code <= 90) {
            hasUpper = true
          }
        }
        // Detect identifier: '@'
        if (
          indexOfIdentifier !== -1 &&
          indexOfIdentifier > start &&
          indexOfIdentifier < end
        ) {
          start = indexOfIdentifier + 1
        }
        // Handle ipv6 addresses
        if (url.charCodeAt(start) === 91 /* '[' */) {
          if (indexOfClosingBracket !== -1) {
            return url.slice(start + 1, indexOfClosingBracket).toLowerCase()
          }
          return null
        } else if (
          indexOfPort !== -1 &&
          indexOfPort > start &&
          indexOfPort < end
        ) {
          // Detect port: ':'
          end = indexOfPort
        }
      }
      // Trim trailing dots
      while (end > start + 1 && url.charCodeAt(end - 1) === 46 /* '.' */) {
        end -= 1
      }
      const hostname =
        start !== 0 || end !== url.length ? url.slice(start, end) : url
      if (hasUpper) {
        return hostname.toLowerCase()
      }
      return hostname
    } // CONCATENATED MODULE: ../../node_modules/tldts-core/dist/es6/src/is-ip.js
    /**
     * Check if a hostname is an IP. You should be aware that this only works
     * because `hostname` is already garanteed to be a valid hostname!
     */
    function isProbablyIpv4(hostname) {
      // Cannot be shorted than 1.1.1.1
      if (hostname.length < 7) {
        return false
      }
      // Cannot be longer than: 255.255.255.255
      if (hostname.length > 15) {
        return false
      }
      let numberOfDots = 0
      for (let i = 0; i < hostname.length; i += 1) {
        const code = hostname.charCodeAt(i)
        if (code === 46 /* '.' */) {
          numberOfDots += 1
        } else if (code < 48 /* '0' */ || code > 57 /* '9' */) {
          return false
        }
      }
      return (
        numberOfDots === 3 &&
        hostname.charCodeAt(0) !== 46 /* '.' */ &&
        hostname.charCodeAt(hostname.length - 1) !== 46 /* '.' */
      )
    }
    /**
     * Similar to isProbablyIpv4.
     */
    function isProbablyIpv6(hostname) {
      if (hostname.length < 3) {
        return false
      }
      let start = hostname.startsWith("[") ? 1 : 0
      let end = hostname.length
      if (hostname[end - 1] === "]") {
        end -= 1
      }
      // We only consider the maximum size of a normal IPV6. Note that this will
      // fail on so-called "IPv4 mapped IPv6 addresses" but this is a corner-case
      // and a proper validation library should be used for these.
      if (end - start > 39) {
        return false
      }
      let hasColon = false
      for (; start < end; start += 1) {
        const code = hostname.charCodeAt(start)
        if (code === 58 /* ':' */) {
          hasColon = true
        } else if (
          !(
            (
              (code >= 48 && code <= 57) ||
              // 0-9
              (code >= 97 && code <= 102) ||
              // a-f
              (code >= 65 && code <= 90)
            ) // A-F
          )
        ) {
          return false
        }
      }
      return hasColon
    }
    /**
     * Check if `hostname` is *probably* a valid ip addr (either ipv6 or ipv4).
     * This *will not* work on any string. We need `hostname` to be a valid
     * hostname.
     */
    function isIp(hostname) {
      return isProbablyIpv6(hostname) || isProbablyIpv4(hostname)
    } // CONCATENATED MODULE: ../../node_modules/tldts-core/dist/es6/src/is-valid.js
    /**
     * Implements fast shallow verification of hostnames. This does not perform a
     * struct check on the content of labels (classes of Unicode characters, etc.)
     * but instead check that the structure is valid (number of labels, length of
     * labels, etc.).
     *
     * If you need stricter validation, consider using an external library.
     */
    function isValidAscii(code) {
      return (
        (code >= 97 && code <= 122) || (code >= 48 && code <= 57) || code > 127
      )
    }
    /**
     * Check if a hostname string is valid. It's usually a preliminary check before
     * trying to use getDomain or anything else.
     *
     * Beware: it does not check if the TLD exists.
     */
    /* harmony default export */ function is_valid(hostname) {
      if (hostname.length > 255) {
        return false
      }
      if (hostname.length === 0) {
        return false
      }
      if (
        /*@__INLINE__*/ !isValidAscii(hostname.charCodeAt(0)) &&
        hostname.charCodeAt(0) !== 46 &&
        // '.' (dot)
        hostname.charCodeAt(0) !== 95 // '_' (underscore)
      ) {
        return false
      }
      // Validate hostname according to RFC
      let lastDotIndex = -1
      let lastCharCode = -1
      const len = hostname.length
      for (let i = 0; i < len; i += 1) {
        const code = hostname.charCodeAt(i)
        if (code === 46 /* '.' */) {
          if (
            // Check that previous label is < 63 bytes long (64 = 63 + '.')
            i - lastDotIndex > 64 ||
            // Check that previous character was not already a '.'
            lastCharCode === 46 ||
            // Check that the previous label does not end with a '-' (dash)
            lastCharCode === 45 ||
            // Check that the previous label does not end with a '_' (underscore)
            lastCharCode === 95
          ) {
            return false
          }
          lastDotIndex = i
        } else if (
          !(/*@__INLINE__*/ (isValidAscii(code) || code === 45 || code === 95))
        ) {
          // Check if there is a forbidden character in the label
          return false
        }
        lastCharCode = code
      }
      return (
        // Check that last label is shorter than 63 chars
        len - lastDotIndex - 1 <= 63 &&
        // Check that the last character is an allowed trailing label character.
        // Since we already checked that the char is a valid hostname character,
        // we only need to check that it's different from '-'.
        lastCharCode !== 45
      )
    } // CONCATENATED MODULE: ../../node_modules/tldts-core/dist/es6/src/options.js
    function setDefaultsImpl({
      allowIcannDomains = true,
      allowPrivateDomains = false,
      detectIp = true,
      extractHostname = true,
      mixedInputs = true,
      validHosts = null,
      validateHostname = true,
    }) {
      return {
        allowIcannDomains,
        allowPrivateDomains,
        detectIp,
        extractHostname,
        mixedInputs,
        validHosts,
        validateHostname,
      }
    }
    const DEFAULT_OPTIONS = /*@__INLINE__*/ setDefaultsImpl({})
    function setDefaults(options) {
      if (options === undefined) {
        return DEFAULT_OPTIONS
      }
      return /*@__INLINE__*/ setDefaultsImpl(options)
    } // CONCATENATED MODULE: ../../node_modules/tldts-core/dist/es6/src/subdomain.js
    /**
     * Returns the subdomain of a hostname string
     */
    function getSubdomain(hostname, domain) {
      // If `hostname` and `domain` are the same, then there is no sub-domain
      if (domain.length === hostname.length) {
        return ""
      }
      return hostname.slice(0, -domain.length - 1)
    } // CONCATENATED MODULE: ../../node_modules/tldts-core/dist/es6/src/factory.js
    /**
     * Implement a factory allowing to plug different implementations of suffix
     * lookup (e.g.: using a trie or the packed hashes datastructures). This is used
     * and exposed in `tldts.ts` and `tldts-experimental.ts` bundle entrypoints.
     */

    function getEmptyResult() {
      return {
        domain: null,
        domainWithoutSuffix: null,
        hostname: null,
        isIcann: null,
        isIp: null,
        isPrivate: null,
        publicSuffix: null,
        subdomain: null,
      }
    }
    function factory_resetResult(result) {
      result.domain = null
      result.domainWithoutSuffix = null
      result.hostname = null
      result.isIcann = null
      result.isIp = null
      result.isPrivate = null
      result.publicSuffix = null
      result.subdomain = null
    }
    function factory_parseImpl(
      url,
      step,
      suffixLookup,
      partialOptions,
      result,
    ) {
      const options = /*@__INLINE__*/ setDefaults(partialOptions)
      // Very fast approximate check to make sure `url` is a string. This is needed
      // because the library will not necessarily be used in a typed setup and
      // values of arbitrary types might be given as argument.
      if (typeof url !== "string") {
        return result
      }
      // Extract hostname from `url` only if needed. This can be made optional
      // using `options.extractHostname`. This option will typically be used
      // whenever we are sure the inputs to `parse` are already hostnames and not
      // arbitrary URLs.
      //
      // `mixedInput` allows to specify if we expect a mix of URLs and hostnames
      // as input. If only hostnames are expected then `extractHostname` can be
      // set to `false` to speed-up parsing. If only URLs are expected then
      // `mixedInputs` can be set to `false`. The `mixedInputs` is only a hint
      // and will not change the behavior of the library.
      if (!options.extractHostname) {
        result.hostname = url
      } else if (options.mixedInputs) {
        result.hostname = extractHostname(url, is_valid(url))
      } else {
        result.hostname = extractHostname(url, false)
      }
      if (step === 0 /* FLAG.HOSTNAME */ || result.hostname === null) {
        return result
      }
      // Check if `hostname` is a valid ip address
      if (options.detectIp) {
        result.isIp = isIp(result.hostname)
        if (result.isIp) {
          return result
        }
      }
      // Perform optional hostname validation. If hostname is not valid, no need to
      // go further as there will be no valid domain or sub-domain.
      if (
        options.validateHostname &&
        options.extractHostname &&
        !is_valid(result.hostname)
      ) {
        result.hostname = null
        return result
      }
      // Extract public suffix
      suffixLookup(result.hostname, options, result)
      if (step === 2 /* FLAG.PUBLIC_SUFFIX */ || result.publicSuffix === null) {
        return result
      }
      // Extract domain
      result.domain = getDomain(result.publicSuffix, result.hostname, options)
      if (step === 3 /* FLAG.DOMAIN */ || result.domain === null) {
        return result
      }
      // Extract subdomain
      result.subdomain = getSubdomain(result.hostname, result.domain)
      if (step === 4 /* FLAG.SUB_DOMAIN */) {
        return result
      }
      // Extract domain without suffix
      result.domainWithoutSuffix = getDomainWithoutSuffix(
        result.domain,
        result.publicSuffix,
      )
      return result
    } // CONCATENATED MODULE: ../../node_modules/tldts-core/dist/es6/src/lookup/fast-path.js
    /* harmony default export */ function fast_path(hostname, options, out) {
      // Fast path for very popular suffixes; this allows to by-pass lookup
      // completely as well as any extra allocation or string manipulation.
      if (!options.allowPrivateDomains && hostname.length > 3) {
        const last = hostname.length - 1
        const c3 = hostname.charCodeAt(last)
        const c2 = hostname.charCodeAt(last - 1)
        const c1 = hostname.charCodeAt(last - 2)
        const c0 = hostname.charCodeAt(last - 3)
        if (
          c3 === 109 /* 'm' */ &&
          c2 === 111 /* 'o' */ &&
          c1 === 99 /* 'c' */ &&
          c0 === 46 /* '.' */
        ) {
          out.isIcann = true
          out.isPrivate = false
          out.publicSuffix = "com"
          return true
        } else if (
          c3 === 103 /* 'g' */ &&
          c2 === 114 /* 'r' */ &&
          c1 === 111 /* 'o' */ &&
          c0 === 46 /* '.' */
        ) {
          out.isIcann = true
          out.isPrivate = false
          out.publicSuffix = "org"
          return true
        } else if (
          c3 === 117 /* 'u' */ &&
          c2 === 100 /* 'd' */ &&
          c1 === 101 /* 'e' */ &&
          c0 === 46 /* '.' */
        ) {
          out.isIcann = true
          out.isPrivate = false
          out.publicSuffix = "edu"
          return true
        } else if (
          c3 === 118 /* 'v' */ &&
          c2 === 111 /* 'o' */ &&
          c1 === 103 /* 'g' */ &&
          c0 === 46 /* '.' */
        ) {
          out.isIcann = true
          out.isPrivate = false
          out.publicSuffix = "gov"
          return true
        } else if (
          c3 === 116 /* 't' */ &&
          c2 === 101 /* 'e' */ &&
          c1 === 110 /* 'n' */ &&
          c0 === 46 /* '.' */
        ) {
          out.isIcann = true
          out.isPrivate = false
          out.publicSuffix = "net"
          return true
        } else if (
          c3 === 101 /* 'e' */ &&
          c2 === 100 /* 'd' */ &&
          c1 === 46 /* '.' */
        ) {
          out.isIcann = true
          out.isPrivate = false
          out.publicSuffix = "de"
          return true
        }
      }
      return false
    } // CONCATENATED MODULE: ../../node_modules/tldts-core/dist/es6/index.js
    // CONCATENATED MODULE: ../../node_modules/tldts/dist/es6/src/data/trie.js
    const exceptions = (function () {
      const _0 = [1, {}],
        _1 = [
          0,
          {
            city: _0,
          },
        ]
      const exceptions = [
        0,
        {
          ck: [
            0,
            {
              www: _0,
            },
          ],
          jp: [
            0,
            {
              kawasaki: _1,
              kitakyushu: _1,
              kobe: _1,
              nagoya: _1,
              sapporo: _1,
              sendai: _1,
              yokohama: _1,
            },
          ],
        },
      ]
      return exceptions
    })()
    const rules = (function () {
      const _2 = [1, {}],
        _3 = [2, {}],
        _4 = [
          1,
          {
            gov: _2,
            com: _2,
            org: _2,
            net: _2,
            edu: _2,
          },
        ],
        _5 = [
          0,
          {
            "*": _3,
          },
        ],
        _6 = [
          1,
          {
            blogspot: _3,
          },
        ],
        _7 = [
          1,
          {
            gov: _2,
          },
        ],
        _8 = [
          0,
          {
            "*": _2,
          },
        ],
        _9 = [
          0,
          {
            cloud: _3,
          },
        ],
        _10 = [
          1,
          {
            co: _3,
          },
        ],
        _11 = [
          2,
          {
            nodes: _3,
          },
        ],
        _12 = [
          0,
          {
            s3: _3,
          },
        ],
        _13 = [
          0,
          {
            direct: _3,
          },
        ],
        _14 = [
          2,
          {
            id: _3,
          },
        ],
        _15 = [
          0,
          {
            "webview-assets": _3,
          },
        ],
        _16 = [
          0,
          {
            vfs: _3,
            "webview-assets": _3,
          },
        ],
        _17 = [
          0,
          {
            "aws-cloud9": _15,
            cloud9: _16,
          },
        ],
        _18 = [
          0,
          {
            dualstack: _12,
            "analytics-gateway": _3,
            "aws-cloud9": _15,
            cloud9: _16,
          },
        ],
        _19 = [
          0,
          {
            dualstack: _12,
            s3: _3,
            "s3-website": _3,
            "aws-cloud9": _15,
            cloud9: _16,
          },
        ],
        _20 = [
          0,
          {
            dualstack: _12,
            "aws-cloud9": _15,
            cloud9: _16,
          },
        ],
        _21 = [
          0,
          {
            apps: _3,
          },
        ],
        _22 = [
          0,
          {
            paas: _3,
          },
        ],
        _23 = [
          0,
          {
            app: _3,
          },
        ],
        _24 = [
          2,
          {
            eu: _3,
          },
        ],
        _25 = [
          0,
          {
            site: _3,
          },
        ],
        _26 = [
          0,
          {
            pages: _3,
          },
        ],
        _27 = [
          1,
          {
            com: _2,
            edu: _2,
            net: _2,
            org: _2,
          },
        ],
        _28 = [
          0,
          {
            j: _3,
          },
        ],
        _29 = [
          0,
          {
            jelastic: _3,
          },
        ],
        _30 = [
          0,
          {
            user: _3,
          },
        ],
        _31 = [
          1,
          {
            ybo: _3,
          },
        ],
        _32 = [
          0,
          {
            cust: _3,
            reservd: _3,
          },
        ],
        _33 = [
          0,
          {
            cust: _3,
          },
        ],
        _34 = [
          1,
          {
            gov: _2,
            edu: _2,
            mil: _2,
            com: _2,
            org: _2,
            net: _2,
          },
        ],
        _35 = [
          1,
          {
            edu: _2,
            biz: _2,
            net: _2,
            org: _2,
            gov: _2,
            info: _2,
            com: _2,
          },
        ],
        _36 = [
          1,
          {
            gov: _2,
            blogspot: _3,
          },
        ],
        _37 = [
          1,
          {
            framer: _3,
          },
        ],
        _38 = [
          1,
          {
            barsy: _3,
          },
        ],
        _39 = [
          0,
          {
            forgot: _3,
          },
        ],
        _40 = [
          1,
          {
            gs: _2,
          },
        ],
        _41 = [
          0,
          {
            nes: _2,
          },
        ],
        _42 = [
          1,
          {
            k12: _2,
            cc: _2,
            lib: _2,
          },
        ],
        _43 = [
          1,
          {
            cc: _2,
            lib: _2,
          },
        ]
      const rules = [
        0,
        {
          ac: [
            1,
            {
              com: _2,
              edu: _2,
              gov: _2,
              net: _2,
              mil: _2,
              org: _2,
              drr: _3,
            },
          ],
          ad: [
            1,
            {
              nom: _2,
            },
          ],
          ae: [
            1,
            {
              co: _2,
              net: _2,
              org: _2,
              sch: _2,
              ac: _2,
              gov: _2,
              mil: _2,
              blogspot: _3,
            },
          ],
          aero: [
            1,
            {
              "accident-investigation": _2,
              "accident-prevention": _2,
              aerobatic: _2,
              aeroclub: _2,
              aerodrome: _2,
              agents: _2,
              aircraft: _2,
              airline: _2,
              airport: _2,
              "air-surveillance": _2,
              airtraffic: _2,
              "air-traffic-control": _2,
              ambulance: _2,
              amusement: _2,
              association: _2,
              author: _2,
              ballooning: _2,
              broker: _2,
              caa: _2,
              cargo: _2,
              catering: _2,
              certification: _2,
              championship: _2,
              charter: _2,
              civilaviation: _2,
              club: _2,
              conference: _2,
              consultant: _2,
              consulting: _2,
              control: _2,
              council: _2,
              crew: _2,
              design: _2,
              dgca: _2,
              educator: _2,
              emergency: _2,
              engine: _2,
              engineer: _2,
              entertainment: _2,
              equipment: _2,
              exchange: _2,
              express: _2,
              federation: _2,
              flight: _2,
              fuel: _2,
              gliding: _2,
              government: _2,
              groundhandling: _2,
              group: _2,
              hanggliding: _2,
              homebuilt: _2,
              insurance: _2,
              journal: _2,
              journalist: _2,
              leasing: _2,
              logistics: _2,
              magazine: _2,
              maintenance: _2,
              media: _2,
              microlight: _2,
              modelling: _2,
              navigation: _2,
              parachuting: _2,
              paragliding: _2,
              "passenger-association": _2,
              pilot: _2,
              press: _2,
              production: _2,
              recreation: _2,
              repbody: _2,
              res: _2,
              research: _2,
              rotorcraft: _2,
              safety: _2,
              scientist: _2,
              services: _2,
              show: _2,
              skydiving: _2,
              software: _2,
              student: _2,
              trader: _2,
              trading: _2,
              trainer: _2,
              union: _2,
              workinggroup: _2,
              works: _2,
            },
          ],
          af: _4,
          ag: [
            1,
            {
              com: _2,
              org: _2,
              net: _2,
              co: _2,
              nom: _2,
            },
          ],
          ai: [
            1,
            {
              off: _2,
              com: _2,
              net: _2,
              org: _2,
              uwu: _3,
            },
          ],
          al: [
            1,
            {
              com: _2,
              edu: _2,
              gov: _2,
              mil: _2,
              net: _2,
              org: _2,
              blogspot: _3,
            },
          ],
          am: [
            1,
            {
              co: _2,
              com: _2,
              commune: _2,
              net: _2,
              org: _2,
              radio: _3,
              blogspot: _3,
              neko: _3,
              nyaa: _3,
            },
          ],
          ao: [
            1,
            {
              ed: _2,
              gv: _2,
              og: _2,
              co: _2,
              pb: _2,
              it: _2,
            },
          ],
          aq: _2,
          ar: [
            1,
            {
              bet: _2,
              com: _6,
              coop: _2,
              edu: _2,
              gob: _2,
              gov: _2,
              int: _2,
              mil: _2,
              musica: _2,
              mutual: _2,
              net: _2,
              org: _2,
              senasa: _2,
              tur: _2,
            },
          ],
          arpa: [
            1,
            {
              e164: _2,
              "in-addr": _2,
              ip6: _2,
              iris: _2,
              uri: _2,
              urn: _2,
            },
          ],
          as: _7,
          asia: [
            1,
            {
              cloudns: _3,
            },
          ],
          at: [
            1,
            {
              ac: [
                1,
                {
                  sth: _2,
                },
              ],
              co: _6,
              gv: _2,
              or: _2,
              funkfeuer: [
                0,
                {
                  wien: _3,
                },
              ],
              futurecms: [
                0,
                {
                  "*": _3,
                  ex: _5,
                  in: _5,
                },
              ],
              futurehosting: _3,
              futuremailing: _3,
              ortsinfo: [
                0,
                {
                  ex: _5,
                  kunden: _5,
                },
              ],
              biz: _3,
              info: _3,
              "123webseite": _3,
              priv: _3,
              myspreadshop: _3,
              "12hp": _3,
              "2ix": _3,
              "4lima": _3,
              "lima-city": _3,
            },
          ],
          au: [
            1,
            {
              com: [
                1,
                {
                  blogspot: _3,
                  cloudlets: [
                    0,
                    {
                      mel: _3,
                    },
                  ],
                  myspreadshop: _3,
                },
              ],
              net: _2,
              org: _2,
              edu: [
                1,
                {
                  act: _2,
                  catholic: _2,
                  nsw: [
                    1,
                    {
                      schools: _2,
                    },
                  ],
                  nt: _2,
                  qld: _2,
                  sa: _2,
                  tas: _2,
                  vic: _2,
                  wa: _2,
                },
              ],
              gov: [
                1,
                {
                  qld: _2,
                  sa: _2,
                  tas: _2,
                  vic: _2,
                  wa: _2,
                },
              ],
              asn: _2,
              id: _2,
              info: _2,
              conf: _2,
              oz: _2,
              act: _2,
              nsw: _2,
              nt: _2,
              qld: _2,
              sa: _2,
              tas: _2,
              vic: _2,
              wa: _2,
            },
          ],
          aw: [
            1,
            {
              com: _2,
            },
          ],
          ax: [
            1,
            {
              be: _3,
              cat: _3,
              es: _3,
              eu: _3,
              gg: _3,
              mc: _3,
              us: _3,
              xy: _3,
            },
          ],
          az: [
            1,
            {
              com: _2,
              net: _2,
              int: _2,
              gov: _2,
              org: _2,
              edu: _2,
              info: _2,
              pp: _2,
              mil: _2,
              name: _2,
              pro: _2,
              biz: _2,
            },
          ],
          ba: [
            1,
            {
              com: _2,
              edu: _2,
              gov: _2,
              mil: _2,
              net: _2,
              org: _2,
              rs: _3,
              blogspot: _3,
            },
          ],
          bb: [
            1,
            {
              biz: _2,
              co: _2,
              com: _2,
              edu: _2,
              gov: _2,
              info: _2,
              net: _2,
              org: _2,
              store: _2,
              tv: _2,
            },
          ],
          bd: _8,
          be: [
            1,
            {
              ac: _2,
              webhosting: _3,
              blogspot: _3,
              interhostsolutions: _9,
              kuleuven: [
                0,
                {
                  ezproxy: _3,
                },
              ],
              "123website": _3,
              myspreadshop: _3,
              transurl: _5,
            },
          ],
          bf: _7,
          bg: [
            1,
            {
              0: _2,
              1: _2,
              2: _2,
              3: _2,
              4: _2,
              5: _2,
              6: _2,
              7: _2,
              8: _2,
              9: _2,
              a: _2,
              b: _2,
              c: _2,
              d: _2,
              e: _2,
              f: _2,
              g: _2,
              h: _2,
              i: _2,
              j: _2,
              k: _2,
              l: _2,
              m: _2,
              n: _2,
              o: _2,
              p: _2,
              q: _2,
              r: _2,
              s: _2,
              t: _2,
              u: _2,
              v: _2,
              w: _2,
              x: _2,
              y: _2,
              z: _2,
              blogspot: _3,
              barsy: _3,
            },
          ],
          bh: _4,
          bi: [
            1,
            {
              co: _2,
              com: _2,
              edu: _2,
              or: _2,
              org: _2,
            },
          ],
          biz: [
            1,
            {
              activetrail: _3,
              cloudns: _3,
              jozi: _3,
              dyndns: _3,
              "for-better": _3,
              "for-more": _3,
              "for-some": _3,
              "for-the": _3,
              selfip: _3,
              webhop: _3,
              orx: _3,
              mmafan: _3,
              myftp: _3,
              "no-ip": _3,
              dscloud: _3,
            },
          ],
          bj: [
            1,
            {
              africa: _2,
              agro: _2,
              architectes: _2,
              assur: _2,
              avocats: _2,
              co: _2,
              com: _2,
              eco: _2,
              econo: _2,
              edu: _2,
              info: _2,
              loisirs: _2,
              money: _2,
              net: _2,
              org: _2,
              ote: _2,
              resto: _2,
              restaurant: _2,
              tourism: _2,
              univ: _2,
              blogspot: _3,
            },
          ],
          bm: _4,
          bn: [
            1,
            {
              com: _2,
              edu: _2,
              gov: _2,
              net: _2,
              org: _2,
              co: _3,
            },
          ],
          bo: [
            1,
            {
              com: _2,
              edu: _2,
              gob: _2,
              int: _2,
              org: _2,
              net: _2,
              mil: _2,
              tv: _2,
              web: _2,
              academia: _2,
              agro: _2,
              arte: _2,
              blog: _2,
              bolivia: _2,
              ciencia: _2,
              cooperativa: _2,
              democracia: _2,
              deporte: _2,
              ecologia: _2,
              economia: _2,
              empresa: _2,
              indigena: _2,
              industria: _2,
              info: _2,
              medicina: _2,
              movimiento: _2,
              musica: _2,
              natural: _2,
              nombre: _2,
              noticias: _2,
              patria: _2,
              politica: _2,
              profesional: _2,
              plurinacional: _2,
              pueblo: _2,
              revista: _2,
              salud: _2,
              tecnologia: _2,
              tksat: _2,
              transporte: _2,
              wiki: _2,
            },
          ],
          br: [
            1,
            {
              "9guacu": _2,
              abc: _2,
              adm: _2,
              adv: _2,
              agr: _2,
              aju: _2,
              am: _2,
              anani: _2,
              aparecida: _2,
              app: _2,
              arq: _2,
              art: _2,
              ato: _2,
              b: _2,
              barueri: _2,
              belem: _2,
              bhz: _2,
              bib: _2,
              bio: _2,
              blog: _2,
              bmd: _2,
              boavista: _2,
              bsb: _2,
              campinagrande: _2,
              campinas: _2,
              caxias: _2,
              cim: _2,
              cng: _2,
              cnt: _2,
              com: [
                1,
                {
                  blogspot: _3,
                  simplesite: _3,
                },
              ],
              contagem: _2,
              coop: _2,
              coz: _2,
              cri: _2,
              cuiaba: _2,
              curitiba: _2,
              def: _2,
              des: _2,
              det: _2,
              dev: _2,
              ecn: _2,
              eco: _2,
              edu: _2,
              emp: _2,
              enf: _2,
              eng: _2,
              esp: _2,
              etc: _2,
              eti: _2,
              far: _2,
              feira: _2,
              flog: _2,
              floripa: _2,
              fm: _2,
              fnd: _2,
              fortal: _2,
              fot: _2,
              foz: _2,
              fst: _2,
              g12: _2,
              geo: _2,
              ggf: _2,
              goiania: _2,
              gov: [
                1,
                {
                  ac: _2,
                  al: _2,
                  am: _2,
                  ap: _2,
                  ba: _2,
                  ce: _2,
                  df: _2,
                  es: _2,
                  go: _2,
                  ma: _2,
                  mg: _2,
                  ms: _2,
                  mt: _2,
                  pa: _2,
                  pb: _2,
                  pe: _2,
                  pi: _2,
                  pr: _2,
                  rj: _2,
                  rn: _2,
                  ro: _2,
                  rr: _2,
                  rs: _2,
                  sc: _2,
                  se: _2,
                  sp: _2,
                  to: _2,
                },
              ],
              gru: _2,
              imb: _2,
              ind: _2,
              inf: _2,
              jab: _2,
              jampa: _2,
              jdf: _2,
              joinville: _2,
              jor: _2,
              jus: _2,
              leg: [
                1,
                {
                  ac: _3,
                  al: _3,
                  am: _3,
                  ap: _3,
                  ba: _3,
                  ce: _3,
                  df: _3,
                  es: _3,
                  go: _3,
                  ma: _3,
                  mg: _3,
                  ms: _3,
                  mt: _3,
                  pa: _3,
                  pb: _3,
                  pe: _3,
                  pi: _3,
                  pr: _3,
                  rj: _3,
                  rn: _3,
                  ro: _3,
                  rr: _3,
                  rs: _3,
                  sc: _3,
                  se: _3,
                  sp: _3,
                  to: _3,
                },
              ],
              lel: _2,
              log: _2,
              londrina: _2,
              macapa: _2,
              maceio: _2,
              manaus: _2,
              maringa: _2,
              mat: _2,
              med: _2,
              mil: _2,
              morena: _2,
              mp: _2,
              mus: _2,
              natal: _2,
              net: _2,
              niteroi: _2,
              nom: _8,
              not: _2,
              ntr: _2,
              odo: _2,
              ong: _2,
              org: _2,
              osasco: _2,
              palmas: _2,
              poa: _2,
              ppg: _2,
              pro: _2,
              psc: _2,
              psi: _2,
              pvh: _2,
              qsl: _2,
              radio: _2,
              rec: _2,
              recife: _2,
              rep: _2,
              ribeirao: _2,
              rio: _2,
              riobranco: _2,
              riopreto: _2,
              salvador: _2,
              sampa: _2,
              santamaria: _2,
              santoandre: _2,
              saobernardo: _2,
              saogonca: _2,
              seg: _2,
              sjc: _2,
              slg: _2,
              slz: _2,
              sorocaba: _2,
              srv: _2,
              taxi: _2,
              tc: _2,
              tec: _2,
              teo: _2,
              the: _2,
              tmp: _2,
              trd: _2,
              tur: _2,
              tv: _2,
              udi: _2,
              vet: _2,
              vix: _2,
              vlog: _2,
              wiki: _2,
              zlg: _2,
            },
          ],
          bs: [
            1,
            {
              com: _2,
              net: _2,
              org: _2,
              edu: _2,
              gov: _2,
              we: _3,
            },
          ],
          bt: _4,
          bv: _2,
          bw: [
            1,
            {
              co: _2,
              org: _2,
            },
          ],
          by: [
            1,
            {
              gov: _2,
              mil: _2,
              com: _6,
              of: _2,
              mycloud: _3,
              mediatech: _3,
            },
          ],
          bz: [
            1,
            {
              com: _2,
              net: _2,
              org: _2,
              edu: _2,
              gov: _2,
              za: _3,
              gsj: _3,
            },
          ],
          ca: [
            1,
            {
              ab: _2,
              bc: _2,
              mb: _2,
              nb: _2,
              nf: _2,
              nl: _2,
              ns: _2,
              nt: _2,
              nu: _2,
              on: _2,
              pe: _2,
              qc: _2,
              sk: _2,
              yk: _2,
              gc: _2,
              barsy: _3,
              awdev: _5,
              co: _3,
              blogspot: _3,
              "no-ip": _3,
              myspreadshop: _3,
            },
          ],
          cat: _2,
          cc: [
            1,
            {
              cloudns: _3,
              ftpaccess: _3,
              "game-server": _3,
              myphotos: _3,
              scrapping: _3,
              twmail: _3,
              csx: _3,
              fantasyleague: _3,
              spawn: [
                0,
                {
                  instances: _3,
                },
              ],
            },
          ],
          cd: _7,
          cf: _6,
          cg: _2,
          ch: [
            1,
            {
              square7: _3,
              blogspot: _3,
              flow: [
                0,
                {
                  ae: [
                    0,
                    {
                      alp1: _3,
                    },
                  ],
                  appengine: _3,
                },
              ],
              "linkyard-cloud": _3,
              dnsking: _3,
              gotdns: _3,
              "123website": _3,
              myspreadshop: _3,
              firenet: [
                0,
                {
                  "*": _3,
                  svc: _5,
                },
              ],
              "12hp": _3,
              "2ix": _3,
              "4lima": _3,
              "lima-city": _3,
            },
          ],
          ci: [
            1,
            {
              org: _2,
              or: _2,
              com: _2,
              co: _2,
              edu: _2,
              ed: _2,
              ac: _2,
              net: _2,
              go: _2,
              asso: _2,
              "xn--aroport-bya": _2,
              aéroport: _2,
              int: _2,
              presse: _2,
              md: _2,
              gouv: _2,
              fin: _3,
              nl: _3,
            },
          ],
          ck: _8,
          cl: [
            1,
            {
              co: _2,
              gob: _2,
              gov: _2,
              mil: _2,
              blogspot: _3,
            },
          ],
          cm: [
            1,
            {
              co: _2,
              com: _2,
              gov: _2,
              net: _2,
            },
          ],
          cn: [
            1,
            {
              ac: _2,
              com: [
                1,
                {
                  amazonaws: [
                    0,
                    {
                      compute: _5,
                      "cn-north-1": _12,
                      eb: [
                        0,
                        {
                          "cn-north-1": _3,
                          "cn-northwest-1": _3,
                        },
                      ],
                      elb: _5,
                    },
                  ],
                },
              ],
              edu: _2,
              gov: _2,
              net: _2,
              org: _2,
              mil: _2,
              "xn--55qx5d": _2,
              公司: _2,
              "xn--io0a7i": _2,
              网络: _2,
              "xn--od0alg": _2,
              網絡: _2,
              ah: _2,
              bj: _2,
              cq: _2,
              fj: _2,
              gd: _2,
              gs: _2,
              gz: _2,
              gx: _2,
              ha: _2,
              hb: _2,
              he: _2,
              hi: _2,
              hl: _2,
              hn: _2,
              jl: _2,
              js: _2,
              jx: _2,
              ln: _2,
              nm: _2,
              nx: _2,
              qh: _2,
              sc: _2,
              sd: _2,
              sh: _2,
              sn: _2,
              sx: _2,
              tj: _2,
              xj: _2,
              xz: _2,
              yn: _2,
              zj: _2,
              hk: _2,
              mo: _2,
              tw: _2,
              "canva-apps": _3,
              instantcloud: _3,
              quickconnect: _13,
            },
          ],
          co: [
            1,
            {
              arts: _2,
              com: _6,
              edu: _2,
              firm: _2,
              gov: _2,
              info: _2,
              int: _2,
              mil: _2,
              net: _2,
              nom: _2,
              org: _2,
              rec: _2,
              web: _2,
              carrd: _3,
              crd: _3,
              otap: _5,
              leadpages: _3,
              lpages: _3,
              mypi: _3,
              n4t: _3,
              firewalledreplit: _14,
              repl: _14,
              supabase: _3,
            },
          ],
          com: [
            1,
            {
              devcdnaccesso: _5,
              adobeaemcloud: [
                2,
                {
                  dev: _5,
                },
              ],
              airkitapps: _3,
              "airkitapps-au": _3,
              aivencloud: _3,
              kasserver: _3,
              amazonaws: [
                0,
                {
                  compute: _5,
                  "compute-1": _5,
                  "us-east-1": [
                    2,
                    {
                      dualstack: _12,
                      "analytics-gateway": _3,
                      "aws-cloud9": _15,
                      cloud9: _16,
                    },
                  ],
                  "ap-northeast-1": _18,
                  "ap-northeast-2": _19,
                  "ap-south-1": _19,
                  "ap-southeast-1": _20,
                  "ap-southeast-2": _20,
                  "ca-central-1": _19,
                  "eu-central-1": _19,
                  "eu-west-1": _18,
                  "eu-west-2": _19,
                  "eu-west-3": _19,
                  s3: _3,
                  "s3-ap-northeast-1": _3,
                  "s3-ap-northeast-2": _3,
                  "s3-ap-south-1": _3,
                  "s3-ap-southeast-1": _3,
                  "s3-ap-southeast-2": _3,
                  "s3-ca-central-1": _3,
                  "s3-eu-central-1": _3,
                  "s3-eu-west-1": _3,
                  "s3-eu-west-2": _3,
                  "s3-eu-west-3": _3,
                  "s3-external-1": _3,
                  "s3-fips-us-gov-west-1": _3,
                  "s3-sa-east-1": _3,
                  "s3-us-east-2": _3,
                  "s3-us-gov-west-1": _3,
                  "s3-us-west-1": _3,
                  "s3-us-west-2": _3,
                  "s3-website-ap-northeast-1": _3,
                  "s3-website-ap-southeast-1": _3,
                  "s3-website-ap-southeast-2": _3,
                  "s3-website-eu-west-1": _3,
                  "s3-website-sa-east-1": _3,
                  "s3-website-us-east-1": _3,
                  "s3-website-us-west-1": _3,
                  "s3-website-us-west-2": _3,
                  "sa-east-1": _20,
                  "us-east-2": [
                    0,
                    {
                      dualstack: _12,
                      s3: _3,
                      "s3-website": _3,
                      "analytics-gateway": _3,
                      "aws-cloud9": _15,
                      cloud9: _16,
                    },
                  ],
                  "us-west-2": [
                    0,
                    {
                      "analytics-gateway": _3,
                      "aws-cloud9": _15,
                      cloud9: _16,
                    },
                  ],
                  "af-south-1": _17,
                  "ap-east-1": _17,
                  "ap-northeast-3": _17,
                  "eu-north-1": _17,
                  "eu-south-1": _17,
                  "me-south-1": _17,
                  "us-west-1": _17,
                  elb: _5,
                },
              ],
              elasticbeanstalk: [
                2,
                {
                  "ap-northeast-1": _3,
                  "ap-northeast-2": _3,
                  "ap-northeast-3": _3,
                  "ap-south-1": _3,
                  "ap-southeast-1": _3,
                  "ap-southeast-2": _3,
                  "ca-central-1": _3,
                  "eu-central-1": _3,
                  "eu-west-1": _3,
                  "eu-west-2": _3,
                  "eu-west-3": _3,
                  "sa-east-1": _3,
                  "us-east-1": _3,
                  "us-east-2": _3,
                  "us-gov-west-1": _3,
                  "us-west-1": _3,
                  "us-west-2": _3,
                },
              ],
              awsglobalaccelerator: _3,
              siiites: _3,
              appspacehosted: _3,
              appspaceusercontent: _3,
              "on-aptible": _3,
              myasustor: _3,
              "balena-devices": _3,
              betainabox: _3,
              boutir: _3,
              bplaced: _3,
              cafjs: _3,
              "canva-apps": _3,
              br: _3,
              cn: _3,
              de: _3,
              eu: _3,
              jpn: _3,
              mex: _3,
              ru: _3,
              sa: _3,
              uk: _3,
              us: _3,
              za: _3,
              ar: _3,
              hu: _3,
              kr: _3,
              no: _3,
              qc: _3,
              uy: _3,
              africa: _3,
              gr: _3,
              co: _3,
              jdevcloud: _3,
              wpdevcloud: _3,
              cloudcontrolled: _3,
              cloudcontrolapp: _3,
              "cf-ipfs": _3,
              "cloudflare-ipfs": _3,
              trycloudflare: _3,
              "customer-oci": [
                0,
                {
                  "*": _3,
                  oci: _5,
                  ocp: _5,
                  ocs: _5,
                },
              ],
              dattolocal: _3,
              dattorelay: _3,
              dattoweb: _3,
              mydatto: _3,
              builtwithdark: _3,
              datadetect: [
                0,
                {
                  demo: _3,
                  instance: _3,
                },
              ],
              ddns5: _3,
              discordsays: _3,
              discordsez: _3,
              drayddns: _3,
              dreamhosters: _3,
              mydrobo: _3,
              "dyndns-at-home": _3,
              "dyndns-at-work": _3,
              "dyndns-blog": _3,
              "dyndns-free": _3,
              "dyndns-home": _3,
              "dyndns-ip": _3,
              "dyndns-mail": _3,
              "dyndns-office": _3,
              "dyndns-pics": _3,
              "dyndns-remote": _3,
              "dyndns-server": _3,
              "dyndns-web": _3,
              "dyndns-wiki": _3,
              "dyndns-work": _3,
              blogdns: _3,
              cechire: _3,
              dnsalias: _3,
              dnsdojo: _3,
              doesntexist: _3,
              dontexist: _3,
              doomdns: _3,
              "dyn-o-saur": _3,
              dynalias: _3,
              "est-a-la-maison": _3,
              "est-a-la-masion": _3,
              "est-le-patron": _3,
              "est-mon-blogueur": _3,
              "from-ak": _3,
              "from-al": _3,
              "from-ar": _3,
              "from-ca": _3,
              "from-ct": _3,
              "from-dc": _3,
              "from-de": _3,
              "from-fl": _3,
              "from-ga": _3,
              "from-hi": _3,
              "from-ia": _3,
              "from-id": _3,
              "from-il": _3,
              "from-in": _3,
              "from-ks": _3,
              "from-ky": _3,
              "from-ma": _3,
              "from-md": _3,
              "from-mi": _3,
              "from-mn": _3,
              "from-mo": _3,
              "from-ms": _3,
              "from-mt": _3,
              "from-nc": _3,
              "from-nd": _3,
              "from-ne": _3,
              "from-nh": _3,
              "from-nj": _3,
              "from-nm": _3,
              "from-nv": _3,
              "from-oh": _3,
              "from-ok": _3,
              "from-or": _3,
              "from-pa": _3,
              "from-pr": _3,
              "from-ri": _3,
              "from-sc": _3,
              "from-sd": _3,
              "from-tn": _3,
              "from-tx": _3,
              "from-ut": _3,
              "from-va": _3,
              "from-vt": _3,
              "from-wa": _3,
              "from-wi": _3,
              "from-wv": _3,
              "from-wy": _3,
              getmyip: _3,
              gotdns: _3,
              "hobby-site": _3,
              homelinux: _3,
              homeunix: _3,
              iamallama: _3,
              "is-a-anarchist": _3,
              "is-a-blogger": _3,
              "is-a-bookkeeper": _3,
              "is-a-bulls-fan": _3,
              "is-a-caterer": _3,
              "is-a-chef": _3,
              "is-a-conservative": _3,
              "is-a-cpa": _3,
              "is-a-cubicle-slave": _3,
              "is-a-democrat": _3,
              "is-a-designer": _3,
              "is-a-doctor": _3,
              "is-a-financialadvisor": _3,
              "is-a-geek": _3,
              "is-a-green": _3,
              "is-a-guru": _3,
              "is-a-hard-worker": _3,
              "is-a-hunter": _3,
              "is-a-landscaper": _3,
              "is-a-lawyer": _3,
              "is-a-liberal": _3,
              "is-a-libertarian": _3,
              "is-a-llama": _3,
              "is-a-musician": _3,
              "is-a-nascarfan": _3,
              "is-a-nurse": _3,
              "is-a-painter": _3,
              "is-a-personaltrainer": _3,
              "is-a-photographer": _3,
              "is-a-player": _3,
              "is-a-republican": _3,
              "is-a-rockstar": _3,
              "is-a-socialist": _3,
              "is-a-student": _3,
              "is-a-teacher": _3,
              "is-a-techie": _3,
              "is-a-therapist": _3,
              "is-an-accountant": _3,
              "is-an-actor": _3,
              "is-an-actress": _3,
              "is-an-anarchist": _3,
              "is-an-artist": _3,
              "is-an-engineer": _3,
              "is-an-entertainer": _3,
              "is-certified": _3,
              "is-gone": _3,
              "is-into-anime": _3,
              "is-into-cars": _3,
              "is-into-cartoons": _3,
              "is-into-games": _3,
              "is-leet": _3,
              "is-not-certified": _3,
              "is-slick": _3,
              "is-uberleet": _3,
              "is-with-theband": _3,
              "isa-geek": _3,
              "isa-hockeynut": _3,
              issmarterthanyou: _3,
              "likes-pie": _3,
              likescandy: _3,
              "neat-url": _3,
              "saves-the-whales": _3,
              selfip: _3,
              "sells-for-less": _3,
              "sells-for-u": _3,
              servebbs: _3,
              "simple-url": _3,
              "space-to-rent": _3,
              "teaches-yoga": _3,
              writesthisblog: _3,
              digitaloceanspaces: _5,
              ddnsfree: _3,
              ddnsgeek: _3,
              giize: _3,
              gleeze: _3,
              kozow: _3,
              loseyourip: _3,
              ooguy: _3,
              theworkpc: _3,
              mytuleap: _3,
              "tuleap-partners": _3,
              encoreapi: _3,
              evennode: [
                0,
                {
                  "eu-1": _3,
                  "eu-2": _3,
                  "eu-3": _3,
                  "eu-4": _3,
                  "us-1": _3,
                  "us-2": _3,
                  "us-3": _3,
                  "us-4": _3,
                },
              ],
              onfabrica: _3,
              fbsbx: _21,
              "fastly-edge": _3,
              "fastly-terrarium": _3,
              "fastvps-server": _3,
              mydobiss: _3,
              firebaseapp: _3,
              fldrv: _3,
              forgeblocks: _3,
              framercanvas: _3,
              "freebox-os": _3,
              freeboxos: _3,
              freemyip: _3,
              gentapps: _3,
              gentlentapis: _3,
              githubusercontent: _3,
              "0emm": _5,
              appspot: [
                2,
                {
                  r: _5,
                },
              ],
              codespot: _3,
              googleapis: _3,
              googlecode: _3,
              pagespeedmobilizer: _3,
              publishproxy: _3,
              withgoogle: _3,
              withyoutube: _3,
              blogspot: _3,
              awsmppl: _3,
              herokuapp: _3,
              herokussl: _3,
              impertrixcdn: _3,
              impertrix: _3,
              smushcdn: _3,
              wphostedmail: _3,
              wpmucdn: _3,
              pixolino: _3,
              amscompute: _3,
              dopaas: _3,
              "hosted-by-previder": _22,
              hosteur: [
                0,
                {
                  "rag-cloud": _3,
                  "rag-cloud-ch": _3,
                },
              ],
              "ik-server": [
                0,
                {
                  jcloud: _3,
                  "jcloud-ver-jpc": _3,
                },
              ],
              jelastic: [
                0,
                {
                  demo: _3,
                },
              ],
              kilatiron: _3,
              massivegrid: _22,
              wafaicloud: [
                0,
                {
                  jed: _3,
                  lon: _3,
                  ryd: _3,
                },
              ],
              joyent: [
                0,
                {
                  cns: _5,
                },
              ],
              ktistory: _3,
              lpusercontent: _3,
              lmpm: _23,
              linode: [
                0,
                {
                  members: _3,
                  nodebalancer: _5,
                },
              ],
              linodeobjects: _5,
              linodeusercontent: [
                0,
                {
                  ip: _3,
                },
              ],
              barsycenter: _3,
              barsyonline: _3,
              mazeplay: _3,
              miniserver: _3,
              meteorapp: _24,
              hostedpi: _3,
              "mythic-beasts": [
                0,
                {
                  customer: _3,
                  caracal: _3,
                  fentiger: _3,
                  lynx: _3,
                  ocelot: _3,
                  oncilla: _3,
                  onza: _3,
                  sphinx: _3,
                  vs: _3,
                  x: _3,
                  yali: _3,
                },
              ],
              nospamproxy: _9,
              "4u": _3,
              nfshost: _3,
              "001www": _3,
              ddnslive: _3,
              myiphost: _3,
              blogsyte: _3,
              ciscofreak: _3,
              damnserver: _3,
              ditchyourip: _3,
              dnsiskinky: _3,
              dynns: _3,
              geekgalaxy: _3,
              "health-carereform": _3,
              homesecuritymac: _3,
              homesecuritypc: _3,
              myactivedirectory: _3,
              mysecuritycamera: _3,
              "net-freaks": _3,
              onthewifi: _3,
              point2this: _3,
              quicksytes: _3,
              securitytactics: _3,
              serveexchange: _3,
              servehumour: _3,
              servep2p: _3,
              servesarcasm: _3,
              stufftoread: _3,
              unusualperson: _3,
              workisboring: _3,
              "3utilities": _3,
              ddnsking: _3,
              myvnc: _3,
              servebeer: _3,
              servecounterstrike: _3,
              serveftp: _3,
              servegame: _3,
              servehalflife: _3,
              servehttp: _3,
              serveirc: _3,
              servemp3: _3,
              servepics: _3,
              servequake: _3,
              observableusercontent: [
                0,
                {
                  static: _3,
                },
              ],
              simplesite: _3,
              orsites: _3,
              operaunite: _3,
              "authgear-staging": _3,
              authgearapps: _3,
              skygearapp: _3,
              outsystemscloud: _3,
              ownprovider: _3,
              pgfog: _3,
              pagefrontapp: _3,
              pagexl: _3,
              paywhirl: _5,
              gotpantheon: _3,
              "platter-app": _3,
              pleskns: _3,
              "postman-echo": _3,
              prgmr: [
                0,
                {
                  xen: _3,
                },
              ],
              pythonanywhere: _24,
              qualifioapp: _3,
              ladesk: _3,
              qbuser: _3,
              qa2: _3,
              "dev-myqnapcloud": _3,
              "alpha-myqnapcloud": _3,
              myqnapcloud: _3,
              quipelements: _5,
              rackmaze: _3,
              rhcloud: _3,
              render: _23,
              onrender: _3,
              "180r": _3,
              dojin: _3,
              sakuratan: _3,
              sakuraweb: _3,
              x0: _3,
              code: [
                0,
                {
                  builder: _5,
                  "dev-builder": _5,
                  "stg-builder": _5,
                },
              ],
              logoip: _3,
              scrysec: _3,
              "firewall-gateway": _3,
              myshopblocks: _3,
              myshopify: _3,
              shopitsite: _3,
              "1kapp": _3,
              appchizi: _3,
              applinzi: _3,
              sinaapp: _3,
              vipsinaapp: _3,
              "bounty-full": [
                2,
                {
                  alpha: _3,
                  beta: _3,
                },
              ],
              streamlitapp: _3,
              "try-snowplow": _3,
              "stackhero-network": _3,
              "playstation-cloud": _3,
              myspreadshop: _3,
              stdlib: [
                0,
                {
                  api: _3,
                },
              ],
              "temp-dns": _3,
              dsmynas: _3,
              familyds: _3,
              mytabit: _3,
              "tb-hosting": _25,
              reservd: _3,
              thingdustdata: _3,
              bloxcms: _3,
              "townnews-staging": _3,
              typeform: [
                0,
                {
                  pro: _3,
                },
              ],
              hk: _3,
              it: _3,
              vultrobjects: _5,
              wafflecell: _3,
              "reserve-online": _3,
              hotelwithflight: _3,
              remotewd: _3,
              wiardweb: _26,
              messwithdns: _3,
              "woltlab-demo": _3,
              wpenginepowered: [
                2,
                {
                  js: _3,
                },
              ],
              wixsite: _3,
              xnbay: [
                2,
                {
                  u2: _3,
                  "u2-local": _3,
                },
              ],
              yolasite: _3,
            },
          ],
          coop: _2,
          cr: [
            1,
            {
              ac: _2,
              co: _2,
              ed: _2,
              fi: _2,
              go: _2,
              or: _2,
              sa: _2,
            },
          ],
          cu: [
            1,
            {
              com: _2,
              edu: _2,
              org: _2,
              net: _2,
              gov: _2,
              inf: _2,
            },
          ],
          cv: [
            1,
            {
              com: _2,
              edu: _2,
              int: _2,
              nome: _2,
              org: _2,
              blogspot: _3,
            },
          ],
          cw: _27,
          cx: [
            1,
            {
              gov: _2,
              ath: _3,
              info: _3,
            },
          ],
          cy: [
            1,
            {
              ac: _2,
              biz: _2,
              com: [
                1,
                {
                  blogspot: _3,
                  scaleforce: _28,
                },
              ],
              ekloges: _2,
              gov: _2,
              ltd: _2,
              mil: _2,
              net: _2,
              org: _2,
              press: _2,
              pro: _2,
              tm: _2,
            },
          ],
          cz: [
            1,
            {
              co: _3,
              realm: _3,
              e4: _3,
              blogspot: _3,
              metacentrum: [
                0,
                {
                  cloud: _5,
                  custom: _3,
                },
              ],
              muni: [
                0,
                {
                  cloud: [
                    0,
                    {
                      flt: _3,
                      usr: _3,
                    },
                  ],
                },
              ],
            },
          ],
          de: [
            1,
            {
              bplaced: _3,
              square7: _3,
              com: _3,
              cosidns: [
                0,
                {
                  dyn: _3,
                },
              ],
              "dynamisches-dns": _3,
              dnsupdater: _3,
              "internet-dns": _3,
              "l-o-g-i-n": _3,
              dnshome: _3,
              fuettertdasnetz: _3,
              isteingeek: _3,
              istmein: _3,
              lebtimnetz: _3,
              leitungsen: _3,
              traeumtgerade: _3,
              ddnss: [
                2,
                {
                  dyn: _3,
                  dyndns: _3,
                },
              ],
              dyndns1: _3,
              "dyn-ip24": _3,
              "home-webserver": [
                2,
                {
                  dyn: _3,
                },
              ],
              "myhome-server": _3,
              frusky: _5,
              goip: _3,
              blogspot: _3,
              "xn--gnstigbestellen-zvb": _3,
              günstigbestellen: _3,
              "xn--gnstigliefern-wob": _3,
              günstigliefern: _3,
              "hs-heilbronn": [
                0,
                {
                  it: _26,
                },
              ],
              "dyn-berlin": _3,
              "in-berlin": _3,
              "in-brb": _3,
              "in-butter": _3,
              "in-dsl": _3,
              "in-vpn": _3,
              iservschule: _3,
              "mein-iserv": _3,
              schulplattform: _3,
              schulserver: _3,
              "test-iserv": _3,
              keymachine: _3,
              "git-repos": _3,
              "lcube-server": _3,
              "svn-repos": _3,
              barsy: _3,
              "123webseite": _3,
              logoip: _3,
              "firewall-gateway": _3,
              "my-gateway": _3,
              "my-router": _3,
              spdns: _3,
              speedpartner: [
                0,
                {
                  customer: _3,
                },
              ],
              myspreadshop: _3,
              "taifun-dns": _3,
              "12hp": _3,
              "2ix": _3,
              "4lima": _3,
              "lima-city": _3,
              "dd-dns": _3,
              "dray-dns": _3,
              draydns: _3,
              "dyn-vpn": _3,
              dynvpn: _3,
              "mein-vigor": _3,
              "my-vigor": _3,
              "my-wan": _3,
              "syno-ds": _3,
              "synology-diskstation": _3,
              "synology-ds": _3,
              uberspace: _5,
              virtualuser: _3,
              "virtual-user": _3,
              "community-pro": _3,
              diskussionsbereich: _3,
            },
          ],
          dj: _2,
          dk: [
            1,
            {
              biz: _3,
              co: _3,
              firm: _3,
              reg: _3,
              store: _3,
              blogspot: _3,
              "123hjemmeside": _3,
              myspreadshop: _3,
            },
          ],
          dm: _4,
          do: [
            1,
            {
              art: _2,
              com: _2,
              edu: _2,
              gob: _2,
              gov: _2,
              mil: _2,
              net: _2,
              org: _2,
              sld: _2,
              web: _2,
            },
          ],
          dz: [
            1,
            {
              art: _2,
              asso: _2,
              com: _2,
              edu: _2,
              gov: _2,
              org: _2,
              net: _2,
              pol: _2,
              soc: _2,
              tm: _2,
            },
          ],
          ec: [
            1,
            {
              com: _2,
              info: _2,
              net: _2,
              fin: _2,
              k12: _2,
              med: _2,
              pro: _2,
              org: _2,
              edu: _2,
              gov: _2,
              gob: _2,
              mil: _2,
              base: _3,
              official: _3,
            },
          ],
          edu: [
            1,
            {
              rit: [
                0,
                {
                  "git-pages": _3,
                },
              ],
            },
          ],
          ee: [
            1,
            {
              edu: _2,
              gov: _2,
              riik: _2,
              lib: _2,
              med: _2,
              com: _6,
              pri: _2,
              aip: _2,
              org: _2,
              fie: _2,
            },
          ],
          eg: [
            1,
            {
              com: _6,
              edu: _2,
              eun: _2,
              gov: _2,
              mil: _2,
              name: _2,
              net: _2,
              org: _2,
              sci: _2,
            },
          ],
          er: _8,
          es: [
            1,
            {
              com: _6,
              nom: _2,
              org: _2,
              gob: _2,
              edu: _2,
              "123miweb": _3,
              myspreadshop: _3,
            },
          ],
          et: [
            1,
            {
              com: _2,
              gov: _2,
              org: _2,
              edu: _2,
              biz: _2,
              name: _2,
              info: _2,
              net: _2,
            },
          ],
          eu: [
            1,
            {
              airkitapps: _3,
              mycd: _3,
              cloudns: _3,
              dogado: _29,
              barsy: _3,
              wellbeingzone: _3,
              spdns: _3,
              transurl: _5,
              diskstation: _3,
            },
          ],
          fi: [
            1,
            {
              aland: _2,
              dy: _3,
              blogspot: _3,
              "xn--hkkinen-5wa": _3,
              häkkinen: _3,
              iki: _3,
              cloudplatform: [
                0,
                {
                  fi: _3,
                },
              ],
              datacenter: [
                0,
                {
                  demo: _3,
                  paas: _3,
                },
              ],
              kapsi: _3,
              "123kotisivu": _3,
              myspreadshop: _3,
            },
          ],
          fj: [
            1,
            {
              ac: _2,
              biz: _2,
              com: _2,
              gov: _2,
              info: _2,
              mil: _2,
              name: _2,
              net: _2,
              org: _2,
              pro: _2,
            },
          ],
          fk: _8,
          fm: [
            1,
            {
              com: _2,
              edu: _2,
              net: _2,
              org: _2,
              radio: _3,
              user: _5,
            },
          ],
          fo: _2,
          fr: [
            1,
            {
              asso: _2,
              com: _2,
              gouv: _2,
              nom: _2,
              prd: _2,
              tm: _2,
              aeroport: _2,
              avocat: _2,
              avoues: _2,
              cci: _2,
              chambagri: _2,
              "chirurgiens-dentistes": _2,
              "experts-comptables": _2,
              "geometre-expert": _2,
              greta: _2,
              "huissier-justice": _2,
              medecin: _2,
              notaires: _2,
              pharmacien: _2,
              port: _2,
              veterinaire: _2,
              "en-root": _3,
              "fbx-os": _3,
              fbxos: _3,
              "freebox-os": _3,
              freeboxos: _3,
              blogspot: _3,
              goupile: _3,
              "123siteweb": _3,
              "on-web": _3,
              "chirurgiens-dentistes-en-france": _3,
              dedibox: _3,
              myspreadshop: _3,
              ynh: _3,
            },
          ],
          ga: _2,
          gb: _2,
          gd: [
            1,
            {
              edu: _2,
              gov: _2,
            },
          ],
          ge: [
            1,
            {
              com: _2,
              edu: _2,
              gov: _2,
              org: _2,
              mil: _2,
              net: _2,
              pvt: _2,
            },
          ],
          gf: _2,
          gg: [
            1,
            {
              co: _2,
              net: _2,
              org: _2,
              kaas: _3,
              cya: _3,
              panel: [
                2,
                {
                  daemon: _3,
                },
              ],
            },
          ],
          gh: [
            1,
            {
              com: _2,
              edu: _2,
              gov: _2,
              org: _2,
              mil: _2,
            },
          ],
          gi: [
            1,
            {
              com: _2,
              ltd: _2,
              gov: _2,
              mod: _2,
              edu: _2,
              org: _2,
            },
          ],
          gl: [
            1,
            {
              co: _2,
              com: _2,
              edu: _2,
              net: _2,
              org: _2,
              biz: _3,
              xx: _3,
            },
          ],
          gm: _2,
          gn: [
            1,
            {
              ac: _2,
              com: _2,
              edu: _2,
              gov: _2,
              org: _2,
              net: _2,
            },
          ],
          gov: _2,
          gp: [
            1,
            {
              com: _2,
              net: _2,
              mobi: _2,
              edu: _2,
              org: _2,
              asso: _2,
              app: _3,
            },
          ],
          gq: _2,
          gr: [
            1,
            {
              com: _2,
              edu: _2,
              net: _2,
              org: _2,
              gov: _2,
              blogspot: _3,
              simplesite: _3,
            },
          ],
          gs: _2,
          gt: [
            1,
            {
              com: _2,
              edu: _2,
              gob: _2,
              ind: _2,
              mil: _2,
              net: _2,
              org: _2,
              blog: _3,
              de: _3,
              to: _3,
            },
          ],
          gu: [
            1,
            {
              com: _2,
              edu: _2,
              gov: _2,
              guam: _2,
              info: _2,
              net: _2,
              org: _2,
              web: _2,
            },
          ],
          gw: _2,
          gy: [
            1,
            {
              co: _2,
              com: _2,
              edu: _2,
              gov: _2,
              net: _2,
              org: _2,
              be: _3,
            },
          ],
          hk: [
            1,
            {
              com: _2,
              edu: _2,
              gov: _2,
              idv: _2,
              net: _2,
              org: _2,
              "xn--55qx5d": _2,
              公司: _2,
              "xn--wcvs22d": _2,
              教育: _2,
              "xn--lcvr32d": _2,
              敎育: _2,
              "xn--mxtq1m": _2,
              政府: _2,
              "xn--gmqw5a": _2,
              個人: _2,
              "xn--ciqpn": _2,
              个人: _2,
              "xn--gmq050i": _2,
              箇人: _2,
              "xn--zf0avx": _2,
              網络: _2,
              "xn--io0a7i": _2,
              网络: _2,
              "xn--mk0axi": _2,
              组織: _2,
              "xn--od0alg": _2,
              網絡: _2,
              "xn--od0aq3b": _2,
              网絡: _2,
              "xn--tn0ag": _2,
              组织: _2,
              "xn--uc0atv": _2,
              組織: _2,
              "xn--uc0ay4a": _2,
              組织: _2,
              blogspot: _3,
              secaas: _3,
              ltd: _3,
              inc: _3,
            },
          ],
          hm: _2,
          hn: [
            1,
            {
              com: _2,
              edu: _2,
              org: _2,
              net: _2,
              mil: _2,
              gob: _2,
              cc: _3,
            },
          ],
          hr: [
            1,
            {
              iz: _2,
              from: _2,
              name: _2,
              com: _2,
              blogspot: _3,
              free: _3,
            },
          ],
          ht: [
            1,
            {
              com: _2,
              shop: _2,
              firm: _2,
              info: _2,
              adult: _2,
              net: _2,
              pro: _2,
              org: _2,
              med: _2,
              art: _2,
              coop: _2,
              pol: _2,
              asso: _2,
              edu: _2,
              rel: _2,
              gouv: _2,
              perso: _2,
            },
          ],
          hu: [
            1,
            {
              2000: _2,
              co: _2,
              info: _2,
              org: _2,
              priv: _2,
              sport: _2,
              tm: _2,
              agrar: _2,
              bolt: _2,
              casino: _2,
              city: _2,
              erotica: _2,
              erotika: _2,
              film: _2,
              forum: _2,
              games: _2,
              hotel: _2,
              ingatlan: _2,
              jogasz: _2,
              konyvelo: _2,
              lakas: _2,
              media: _2,
              news: _2,
              reklam: _2,
              sex: _2,
              shop: _2,
              suli: _2,
              szex: _2,
              tozsde: _2,
              utazas: _2,
              video: _2,
              blogspot: _3,
            },
          ],
          id: [
            1,
            {
              ac: _2,
              biz: _2,
              co: _6,
              desa: _2,
              go: _2,
              mil: _2,
              my: [
                1,
                {
                  rss: _5,
                },
              ],
              net: _2,
              or: _2,
              ponpes: _2,
              sch: _2,
              web: _2,
              flap: _3,
              forte: _3,
            },
          ],
          ie: [
            1,
            {
              gov: _2,
              blogspot: _3,
              myspreadshop: _3,
            },
          ],
          il: [
            1,
            {
              ac: _2,
              co: [
                1,
                {
                  ravpage: _3,
                  blogspot: _3,
                  tabitorder: _3,
                  mytabit: _3,
                },
              ],
              gov: _2,
              idf: _2,
              k12: _2,
              muni: _2,
              net: _2,
              org: _2,
            },
          ],
          "xn--4dbrk0ce": [
            1,
            {
              "xn--4dbgdty6c": _2,
              "xn--5dbhl8d": _2,
              "xn--8dbq2a": _2,
              "xn--hebda8b": _2,
            },
          ],
          ישראל: [
            1,
            {
              אקדמיה: _2,
              ישוב: _2,
              צהל: _2,
              ממשל: _2,
            },
          ],
          im: [
            1,
            {
              ac: _2,
              co: [
                1,
                {
                  ltd: _2,
                  plc: _2,
                },
              ],
              com: _2,
              net: _2,
              org: _2,
              tt: _2,
              tv: _2,
              ro: _3,
            },
          ],
          in: [
            1,
            {
              "5g": _2,
              "6g": _2,
              ac: _2,
              ai: _2,
              am: _2,
              bihar: _2,
              biz: _2,
              business: _2,
              ca: _2,
              cn: _2,
              co: _2,
              com: _2,
              coop: _2,
              cs: _2,
              delhi: _2,
              dr: _2,
              edu: _2,
              er: _2,
              firm: _2,
              gen: _2,
              gov: _2,
              gujarat: _2,
              ind: _2,
              info: _2,
              int: _2,
              internet: _2,
              io: _2,
              me: _2,
              mil: _2,
              net: _2,
              nic: _2,
              org: _2,
              pg: _2,
              post: _2,
              pro: _2,
              res: _2,
              travel: _2,
              tv: _2,
              uk: _2,
              up: _2,
              us: _2,
              web: _3,
              cloudns: _3,
              blogspot: _3,
              barsy: _3,
              supabase: _3,
            },
          ],
          info: [
            1,
            {
              cloudns: _3,
              "dynamic-dns": _3,
              dyndns: _3,
              "barrel-of-knowledge": _3,
              "barrell-of-knowledge": _3,
              "for-our": _3,
              "groks-the": _3,
              "groks-this": _3,
              "here-for-more": _3,
              knowsitall: _3,
              selfip: _3,
              webhop: _3,
              barsy: _3,
              mayfirst: _3,
              forumz: _3,
              nsupdate: _3,
              dvrcam: _3,
              ilovecollege: _3,
              "no-ip": _3,
              dnsupdate: _3,
              "v-info": _3,
            },
          ],
          int: [
            1,
            {
              eu: _2,
            },
          ],
          io: [
            1,
            {
              2038: _3,
              com: _2,
              "on-acorn": _5,
              apigee: _3,
              "b-data": _3,
              backplaneapp: _3,
              banzaicloud: [
                0,
                {
                  app: _3,
                  backyards: _5,
                },
              ],
              beagleboard: _3,
              bitbucket: _3,
              bluebite: _3,
              boxfuse: _3,
              browsersafetymark: _3,
              bigv: [
                0,
                {
                  uk0: _3,
                },
              ],
              cleverapps: _3,
              dappnode: [
                0,
                {
                  dyndns: _3,
                },
              ],
              dedyn: _3,
              drud: _3,
              definima: _3,
              "fh-muenster": _3,
              shw: _3,
              forgerock: [
                0,
                {
                  id: _3,
                },
              ],
              ghost: _3,
              github: _3,
              gitlab: _3,
              lolipop: _3,
              "hasura-app": _3,
              hostyhosting: _3,
              moonscale: _5,
              beebyte: _22,
              beebyteapp: [
                0,
                {
                  sekd1: _3,
                },
              ],
              jele: _3,
              unispace: [
                0,
                {
                  "cloud-fr1": _3,
                },
              ],
              webthings: _3,
              loginline: _3,
              barsy: _3,
              azurecontainer: _5,
              ngrok: [
                2,
                {
                  ap: _3,
                  au: _3,
                  eu: _3,
                  in: _3,
                  jp: _3,
                  sa: _3,
                  us: _3,
                },
              ],
              nodeart: [
                0,
                {
                  stage: _3,
                },
              ],
              nid: _3,
              pantheonsite: _3,
              dyn53: _3,
              pstmn: [
                2,
                {
                  mock: _3,
                },
              ],
              protonet: _3,
              qoto: _3,
              qcx: [
                2,
                {
                  sys: _5,
                },
              ],
              vaporcloud: _3,
              vbrplsbx: [
                0,
                {
                  g: _3,
                },
              ],
              "on-k3s": _5,
              "on-rio": _5,
              readthedocs: _3,
              resindevice: _3,
              resinstaging: [
                0,
                {
                  devices: _3,
                },
              ],
              hzc: _3,
              sandcats: _3,
              shiftcrypto: _3,
              shiftedit: _3,
              "mo-siemens": _3,
              musician: _3,
              lair: _21,
              stolos: _5,
              spacekit: _3,
              utwente: _3,
              s5y: _5,
              edugit: _3,
              telebit: _3,
              thingdust: [
                0,
                {
                  dev: _32,
                  disrec: _32,
                  prod: _33,
                  testing: _32,
                },
              ],
              tickets: _3,
              upli: _3,
              wedeploy: _3,
              editorx: _3,
              basicserver: _3,
              virtualserver: _3,
            },
          ],
          iq: _34,
          ir: [
            1,
            {
              ac: _2,
              co: _2,
              gov: _2,
              id: _2,
              net: _2,
              org: _2,
              sch: _2,
              "xn--mgba3a4f16a": _2,
              ایران: _2,
              "xn--mgba3a4fra": _2,
              ايران: _2,
            },
          ],
          is: [
            1,
            {
              net: _2,
              com: _2,
              edu: _2,
              gov: _2,
              org: _2,
              int: _2,
              cupcake: _3,
              blogspot: _3,
            },
          ],
          it: [
            1,
            {
              gov: _2,
              edu: _2,
              abr: _2,
              abruzzo: _2,
              "aosta-valley": _2,
              aostavalley: _2,
              bas: _2,
              basilicata: _2,
              cal: _2,
              calabria: _2,
              cam: _2,
              campania: _2,
              "emilia-romagna": _2,
              emiliaromagna: _2,
              emr: _2,
              "friuli-v-giulia": _2,
              "friuli-ve-giulia": _2,
              "friuli-vegiulia": _2,
              "friuli-venezia-giulia": _2,
              "friuli-veneziagiulia": _2,
              "friuli-vgiulia": _2,
              "friuliv-giulia": _2,
              "friulive-giulia": _2,
              friulivegiulia: _2,
              "friulivenezia-giulia": _2,
              friuliveneziagiulia: _2,
              friulivgiulia: _2,
              fvg: _2,
              laz: _2,
              lazio: _2,
              lig: _2,
              liguria: _2,
              lom: _2,
              lombardia: _2,
              lombardy: _2,
              lucania: _2,
              mar: _2,
              marche: _2,
              mol: _2,
              molise: _2,
              piedmont: _2,
              piemonte: _2,
              pmn: _2,
              pug: _2,
              puglia: _2,
              sar: _2,
              sardegna: _2,
              sardinia: _2,
              sic: _2,
              sicilia: _2,
              sicily: _2,
              taa: _2,
              tos: _2,
              toscana: _2,
              "trentin-sud-tirol": _2,
              "xn--trentin-sd-tirol-rzb": _2,
              "trentin-süd-tirol": _2,
              "trentin-sudtirol": _2,
              "xn--trentin-sdtirol-7vb": _2,
              "trentin-südtirol": _2,
              "trentin-sued-tirol": _2,
              "trentin-suedtirol": _2,
              "trentino-a-adige": _2,
              "trentino-aadige": _2,
              "trentino-alto-adige": _2,
              "trentino-altoadige": _2,
              "trentino-s-tirol": _2,
              "trentino-stirol": _2,
              "trentino-sud-tirol": _2,
              "xn--trentino-sd-tirol-c3b": _2,
              "trentino-süd-tirol": _2,
              "trentino-sudtirol": _2,
              "xn--trentino-sdtirol-szb": _2,
              "trentino-südtirol": _2,
              "trentino-sued-tirol": _2,
              "trentino-suedtirol": _2,
              trentino: _2,
              "trentinoa-adige": _2,
              trentinoaadige: _2,
              "trentinoalto-adige": _2,
              trentinoaltoadige: _2,
              "trentinos-tirol": _2,
              trentinostirol: _2,
              "trentinosud-tirol": _2,
              "xn--trentinosd-tirol-rzb": _2,
              "trentinosüd-tirol": _2,
              trentinosudtirol: _2,
              "xn--trentinosdtirol-7vb": _2,
              trentinosüdtirol: _2,
              "trentinosued-tirol": _2,
              trentinosuedtirol: _2,
              "trentinsud-tirol": _2,
              "xn--trentinsd-tirol-6vb": _2,
              "trentinsüd-tirol": _2,
              trentinsudtirol: _2,
              "xn--trentinsdtirol-nsb": _2,
              trentinsüdtirol: _2,
              "trentinsued-tirol": _2,
              trentinsuedtirol: _2,
              tuscany: _2,
              umb: _2,
              umbria: _2,
              "val-d-aosta": _2,
              "val-daosta": _2,
              "vald-aosta": _2,
              valdaosta: _2,
              "valle-aosta": _2,
              "valle-d-aosta": _2,
              "valle-daosta": _2,
              valleaosta: _2,
              "valled-aosta": _2,
              valledaosta: _2,
              "vallee-aoste": _2,
              "xn--valle-aoste-ebb": _2,
              "vallée-aoste": _2,
              "vallee-d-aoste": _2,
              "xn--valle-d-aoste-ehb": _2,
              "vallée-d-aoste": _2,
              valleeaoste: _2,
              "xn--valleaoste-e7a": _2,
              valléeaoste: _2,
              valleedaoste: _2,
              "xn--valledaoste-ebb": _2,
              valléedaoste: _2,
              vao: _2,
              vda: _2,
              ven: _2,
              veneto: _2,
              ag: _2,
              agrigento: _2,
              al: _2,
              alessandria: _2,
              "alto-adige": _2,
              altoadige: _2,
              an: _2,
              ancona: _2,
              "andria-barletta-trani": _2,
              "andria-trani-barletta": _2,
              andriabarlettatrani: _2,
              andriatranibarletta: _2,
              ao: _2,
              aosta: _2,
              aoste: _2,
              ap: _2,
              aq: _2,
              aquila: _2,
              ar: _2,
              arezzo: _2,
              "ascoli-piceno": _2,
              ascolipiceno: _2,
              asti: _2,
              at: _2,
              av: _2,
              avellino: _2,
              ba: _2,
              "balsan-sudtirol": _2,
              "xn--balsan-sdtirol-nsb": _2,
              "balsan-südtirol": _2,
              "balsan-suedtirol": _2,
              balsan: _2,
              bari: _2,
              "barletta-trani-andria": _2,
              barlettatraniandria: _2,
              belluno: _2,
              benevento: _2,
              bergamo: _2,
              bg: _2,
              bi: _2,
              biella: _2,
              bl: _2,
              bn: _2,
              bo: _2,
              bologna: _2,
              "bolzano-altoadige": _2,
              bolzano: _2,
              "bozen-sudtirol": _2,
              "xn--bozen-sdtirol-2ob": _2,
              "bozen-südtirol": _2,
              "bozen-suedtirol": _2,
              bozen: _2,
              br: _2,
              brescia: _2,
              brindisi: _2,
              bs: _2,
              bt: _2,
              "bulsan-sudtirol": _2,
              "xn--bulsan-sdtirol-nsb": _2,
              "bulsan-südtirol": _2,
              "bulsan-suedtirol": _2,
              bulsan: _2,
              bz: _2,
              ca: _2,
              cagliari: _2,
              caltanissetta: _2,
              "campidano-medio": _2,
              campidanomedio: _2,
              campobasso: _2,
              "carbonia-iglesias": _2,
              carboniaiglesias: _2,
              "carrara-massa": _2,
              carraramassa: _2,
              caserta: _2,
              catania: _2,
              catanzaro: _2,
              cb: _2,
              ce: _2,
              "cesena-forli": _2,
              "xn--cesena-forl-mcb": _2,
              "cesena-forlì": _2,
              cesenaforli: _2,
              "xn--cesenaforl-i8a": _2,
              cesenaforlì: _2,
              ch: _2,
              chieti: _2,
              ci: _2,
              cl: _2,
              cn: _2,
              co: _2,
              como: _2,
              cosenza: _2,
              cr: _2,
              cremona: _2,
              crotone: _2,
              cs: _2,
              ct: _2,
              cuneo: _2,
              cz: _2,
              "dell-ogliastra": _2,
              dellogliastra: _2,
              en: _2,
              enna: _2,
              fc: _2,
              fe: _2,
              fermo: _2,
              ferrara: _2,
              fg: _2,
              fi: _2,
              firenze: _2,
              florence: _2,
              fm: _2,
              foggia: _2,
              "forli-cesena": _2,
              "xn--forl-cesena-fcb": _2,
              "forlì-cesena": _2,
              forlicesena: _2,
              "xn--forlcesena-c8a": _2,
              forlìcesena: _2,
              fr: _2,
              frosinone: _2,
              ge: _2,
              genoa: _2,
              genova: _2,
              go: _2,
              gorizia: _2,
              gr: _2,
              grosseto: _2,
              "iglesias-carbonia": _2,
              iglesiascarbonia: _2,
              im: _2,
              imperia: _2,
              is: _2,
              isernia: _2,
              kr: _2,
              "la-spezia": _2,
              laquila: _2,
              laspezia: _2,
              latina: _2,
              lc: _2,
              le: _2,
              lecce: _2,
              lecco: _2,
              li: _2,
              livorno: _2,
              lo: _2,
              lodi: _2,
              lt: _2,
              lu: _2,
              lucca: _2,
              macerata: _2,
              mantova: _2,
              "massa-carrara": _2,
              massacarrara: _2,
              matera: _2,
              mb: _2,
              mc: _2,
              me: _2,
              "medio-campidano": _2,
              mediocampidano: _2,
              messina: _2,
              mi: _2,
              milan: _2,
              milano: _2,
              mn: _2,
              mo: _2,
              modena: _2,
              "monza-brianza": _2,
              "monza-e-della-brianza": _2,
              monza: _2,
              monzabrianza: _2,
              monzaebrianza: _2,
              monzaedellabrianza: _2,
              ms: _2,
              mt: _2,
              na: _2,
              naples: _2,
              napoli: _2,
              no: _2,
              novara: _2,
              nu: _2,
              nuoro: _2,
              og: _2,
              ogliastra: _2,
              "olbia-tempio": _2,
              olbiatempio: _2,
              or: _2,
              oristano: _2,
              ot: _2,
              pa: _2,
              padova: _2,
              padua: _2,
              palermo: _2,
              parma: _2,
              pavia: _2,
              pc: _2,
              pd: _2,
              pe: _2,
              perugia: _2,
              "pesaro-urbino": _2,
              pesarourbino: _2,
              pescara: _2,
              pg: _2,
              pi: _2,
              piacenza: _2,
              pisa: _2,
              pistoia: _2,
              pn: _2,
              po: _2,
              pordenone: _2,
              potenza: _2,
              pr: _2,
              prato: _2,
              pt: _2,
              pu: _2,
              pv: _2,
              pz: _2,
              ra: _2,
              ragusa: _2,
              ravenna: _2,
              rc: _2,
              re: _2,
              "reggio-calabria": _2,
              "reggio-emilia": _2,
              reggiocalabria: _2,
              reggioemilia: _2,
              rg: _2,
              ri: _2,
              rieti: _2,
              rimini: _2,
              rm: _2,
              rn: _2,
              ro: _2,
              roma: _2,
              rome: _2,
              rovigo: _2,
              sa: _2,
              salerno: _2,
              sassari: _2,
              savona: _2,
              si: _2,
              siena: _2,
              siracusa: _2,
              so: _2,
              sondrio: _2,
              sp: _2,
              sr: _2,
              ss: _2,
              suedtirol: _2,
              "xn--sdtirol-n2a": _2,
              südtirol: _2,
              sv: _2,
              ta: _2,
              taranto: _2,
              te: _2,
              "tempio-olbia": _2,
              tempioolbia: _2,
              teramo: _2,
              terni: _2,
              tn: _2,
              to: _2,
              torino: _2,
              tp: _2,
              tr: _2,
              "trani-andria-barletta": _2,
              "trani-barletta-andria": _2,
              traniandriabarletta: _2,
              tranibarlettaandria: _2,
              trapani: _2,
              trento: _2,
              treviso: _2,
              trieste: _2,
              ts: _2,
              turin: _2,
              tv: _2,
              ud: _2,
              udine: _2,
              "urbino-pesaro": _2,
              urbinopesaro: _2,
              va: _2,
              varese: _2,
              vb: _2,
              vc: _2,
              ve: _2,
              venezia: _2,
              venice: _2,
              verbania: _2,
              vercelli: _2,
              verona: _2,
              vi: _2,
              "vibo-valentia": _2,
              vibovalentia: _2,
              vicenza: _2,
              viterbo: _2,
              vr: _2,
              vs: _2,
              vt: _2,
              vv: _2,
              blogspot: _3,
              ibxos: _3,
              iliadboxos: _3,
              neen: [
                0,
                {
                  jc: _3,
                },
              ],
              tim: [
                0,
                {
                  open: [
                    0,
                    {
                      jelastic: _9,
                    },
                  ],
                },
              ],
              "16-b": _3,
              "32-b": _3,
              "64-b": _3,
              "123homepage": _3,
              myspreadshop: _3,
              syncloud: _3,
            },
          ],
          je: [
            1,
            {
              co: _2,
              net: _2,
              org: _2,
              of: _3,
            },
          ],
          jm: _8,
          jo: [
            1,
            {
              com: _2,
              org: _2,
              net: _2,
              edu: _2,
              sch: _2,
              gov: _2,
              mil: _2,
              name: _2,
            },
          ],
          jobs: _2,
          jp: [
            1,
            {
              ac: _2,
              ad: _2,
              co: _2,
              ed: _2,
              go: _2,
              gr: _2,
              lg: _2,
              ne: [
                1,
                {
                  aseinet: _30,
                  gehirn: _3,
                  ivory: _3,
                  "mail-box": _3,
                  mints: _3,
                  mokuren: _3,
                  opal: _3,
                  sakura: _3,
                  sumomo: _3,
                  topaz: _3,
                },
              ],
              or: _2,
              aichi: [
                1,
                {
                  aisai: _2,
                  ama: _2,
                  anjo: _2,
                  asuke: _2,
                  chiryu: _2,
                  chita: _2,
                  fuso: _2,
                  gamagori: _2,
                  handa: _2,
                  hazu: _2,
                  hekinan: _2,
                  higashiura: _2,
                  ichinomiya: _2,
                  inazawa: _2,
                  inuyama: _2,
                  isshiki: _2,
                  iwakura: _2,
                  kanie: _2,
                  kariya: _2,
                  kasugai: _2,
                  kira: _2,
                  kiyosu: _2,
                  komaki: _2,
                  konan: _2,
                  kota: _2,
                  mihama: _2,
                  miyoshi: _2,
                  nishio: _2,
                  nisshin: _2,
                  obu: _2,
                  oguchi: _2,
                  oharu: _2,
                  okazaki: _2,
                  owariasahi: _2,
                  seto: _2,
                  shikatsu: _2,
                  shinshiro: _2,
                  shitara: _2,
                  tahara: _2,
                  takahama: _2,
                  tobishima: _2,
                  toei: _2,
                  togo: _2,
                  tokai: _2,
                  tokoname: _2,
                  toyoake: _2,
                  toyohashi: _2,
                  toyokawa: _2,
                  toyone: _2,
                  toyota: _2,
                  tsushima: _2,
                  yatomi: _2,
                },
              ],
              akita: [
                1,
                {
                  akita: _2,
                  daisen: _2,
                  fujisato: _2,
                  gojome: _2,
                  hachirogata: _2,
                  happou: _2,
                  higashinaruse: _2,
                  honjo: _2,
                  honjyo: _2,
                  ikawa: _2,
                  kamikoani: _2,
                  kamioka: _2,
                  katagami: _2,
                  kazuno: _2,
                  kitaakita: _2,
                  kosaka: _2,
                  kyowa: _2,
                  misato: _2,
                  mitane: _2,
                  moriyoshi: _2,
                  nikaho: _2,
                  noshiro: _2,
                  odate: _2,
                  oga: _2,
                  ogata: _2,
                  semboku: _2,
                  yokote: _2,
                  yurihonjo: _2,
                },
              ],
              aomori: [
                1,
                {
                  aomori: _2,
                  gonohe: _2,
                  hachinohe: _2,
                  hashikami: _2,
                  hiranai: _2,
                  hirosaki: _2,
                  itayanagi: _2,
                  kuroishi: _2,
                  misawa: _2,
                  mutsu: _2,
                  nakadomari: _2,
                  noheji: _2,
                  oirase: _2,
                  owani: _2,
                  rokunohe: _2,
                  sannohe: _2,
                  shichinohe: _2,
                  shingo: _2,
                  takko: _2,
                  towada: _2,
                  tsugaru: _2,
                  tsuruta: _2,
                },
              ],
              chiba: [
                1,
                {
                  abiko: _2,
                  asahi: _2,
                  chonan: _2,
                  chosei: _2,
                  choshi: _2,
                  chuo: _2,
                  funabashi: _2,
                  futtsu: _2,
                  hanamigawa: _2,
                  ichihara: _2,
                  ichikawa: _2,
                  ichinomiya: _2,
                  inzai: _2,
                  isumi: _2,
                  kamagaya: _2,
                  kamogawa: _2,
                  kashiwa: _2,
                  katori: _2,
                  katsuura: _2,
                  kimitsu: _2,
                  kisarazu: _2,
                  kozaki: _2,
                  kujukuri: _2,
                  kyonan: _2,
                  matsudo: _2,
                  midori: _2,
                  mihama: _2,
                  minamiboso: _2,
                  mobara: _2,
                  mutsuzawa: _2,
                  nagara: _2,
                  nagareyama: _2,
                  narashino: _2,
                  narita: _2,
                  noda: _2,
                  oamishirasato: _2,
                  omigawa: _2,
                  onjuku: _2,
                  otaki: _2,
                  sakae: _2,
                  sakura: _2,
                  shimofusa: _2,
                  shirako: _2,
                  shiroi: _2,
                  shisui: _2,
                  sodegaura: _2,
                  sosa: _2,
                  tako: _2,
                  tateyama: _2,
                  togane: _2,
                  tohnosho: _2,
                  tomisato: _2,
                  urayasu: _2,
                  yachimata: _2,
                  yachiyo: _2,
                  yokaichiba: _2,
                  yokoshibahikari: _2,
                  yotsukaido: _2,
                },
              ],
              ehime: [
                1,
                {
                  ainan: _2,
                  honai: _2,
                  ikata: _2,
                  imabari: _2,
                  iyo: _2,
                  kamijima: _2,
                  kihoku: _2,
                  kumakogen: _2,
                  masaki: _2,
                  matsuno: _2,
                  matsuyama: _2,
                  namikata: _2,
                  niihama: _2,
                  ozu: _2,
                  saijo: _2,
                  seiyo: _2,
                  shikokuchuo: _2,
                  tobe: _2,
                  toon: _2,
                  uchiko: _2,
                  uwajima: _2,
                  yawatahama: _2,
                },
              ],
              fukui: [
                1,
                {
                  echizen: _2,
                  eiheiji: _2,
                  fukui: _2,
                  ikeda: _2,
                  katsuyama: _2,
                  mihama: _2,
                  minamiechizen: _2,
                  obama: _2,
                  ohi: _2,
                  ono: _2,
                  sabae: _2,
                  sakai: _2,
                  takahama: _2,
                  tsuruga: _2,
                  wakasa: _2,
                },
              ],
              fukuoka: [
                1,
                {
                  ashiya: _2,
                  buzen: _2,
                  chikugo: _2,
                  chikuho: _2,
                  chikujo: _2,
                  chikushino: _2,
                  chikuzen: _2,
                  chuo: _2,
                  dazaifu: _2,
                  fukuchi: _2,
                  hakata: _2,
                  higashi: _2,
                  hirokawa: _2,
                  hisayama: _2,
                  iizuka: _2,
                  inatsuki: _2,
                  kaho: _2,
                  kasuga: _2,
                  kasuya: _2,
                  kawara: _2,
                  keisen: _2,
                  koga: _2,
                  kurate: _2,
                  kurogi: _2,
                  kurume: _2,
                  minami: _2,
                  miyako: _2,
                  miyama: _2,
                  miyawaka: _2,
                  mizumaki: _2,
                  munakata: _2,
                  nakagawa: _2,
                  nakama: _2,
                  nishi: _2,
                  nogata: _2,
                  ogori: _2,
                  okagaki: _2,
                  okawa: _2,
                  oki: _2,
                  omuta: _2,
                  onga: _2,
                  onojo: _2,
                  oto: _2,
                  saigawa: _2,
                  sasaguri: _2,
                  shingu: _2,
                  shinyoshitomi: _2,
                  shonai: _2,
                  soeda: _2,
                  sue: _2,
                  tachiarai: _2,
                  tagawa: _2,
                  takata: _2,
                  toho: _2,
                  toyotsu: _2,
                  tsuiki: _2,
                  ukiha: _2,
                  umi: _2,
                  usui: _2,
                  yamada: _2,
                  yame: _2,
                  yanagawa: _2,
                  yukuhashi: _2,
                },
              ],
              fukushima: [
                1,
                {
                  aizubange: _2,
                  aizumisato: _2,
                  aizuwakamatsu: _2,
                  asakawa: _2,
                  bandai: _2,
                  date: _2,
                  fukushima: _2,
                  furudono: _2,
                  futaba: _2,
                  hanawa: _2,
                  higashi: _2,
                  hirata: _2,
                  hirono: _2,
                  iitate: _2,
                  inawashiro: _2,
                  ishikawa: _2,
                  iwaki: _2,
                  izumizaki: _2,
                  kagamiishi: _2,
                  kaneyama: _2,
                  kawamata: _2,
                  kitakata: _2,
                  kitashiobara: _2,
                  koori: _2,
                  koriyama: _2,
                  kunimi: _2,
                  miharu: _2,
                  mishima: _2,
                  namie: _2,
                  nango: _2,
                  nishiaizu: _2,
                  nishigo: _2,
                  okuma: _2,
                  omotego: _2,
                  ono: _2,
                  otama: _2,
                  samegawa: _2,
                  shimogo: _2,
                  shirakawa: _2,
                  showa: _2,
                  soma: _2,
                  sukagawa: _2,
                  taishin: _2,
                  tamakawa: _2,
                  tanagura: _2,
                  tenei: _2,
                  yabuki: _2,
                  yamato: _2,
                  yamatsuri: _2,
                  yanaizu: _2,
                  yugawa: _2,
                },
              ],
              gifu: [
                1,
                {
                  anpachi: _2,
                  ena: _2,
                  gifu: _2,
                  ginan: _2,
                  godo: _2,
                  gujo: _2,
                  hashima: _2,
                  hichiso: _2,
                  hida: _2,
                  higashishirakawa: _2,
                  ibigawa: _2,
                  ikeda: _2,
                  kakamigahara: _2,
                  kani: _2,
                  kasahara: _2,
                  kasamatsu: _2,
                  kawaue: _2,
                  kitagata: _2,
                  mino: _2,
                  minokamo: _2,
                  mitake: _2,
                  mizunami: _2,
                  motosu: _2,
                  nakatsugawa: _2,
                  ogaki: _2,
                  sakahogi: _2,
                  seki: _2,
                  sekigahara: _2,
                  shirakawa: _2,
                  tajimi: _2,
                  takayama: _2,
                  tarui: _2,
                  toki: _2,
                  tomika: _2,
                  wanouchi: _2,
                  yamagata: _2,
                  yaotsu: _2,
                  yoro: _2,
                },
              ],
              gunma: [
                1,
                {
                  annaka: _2,
                  chiyoda: _2,
                  fujioka: _2,
                  higashiagatsuma: _2,
                  isesaki: _2,
                  itakura: _2,
                  kanna: _2,
                  kanra: _2,
                  katashina: _2,
                  kawaba: _2,
                  kiryu: _2,
                  kusatsu: _2,
                  maebashi: _2,
                  meiwa: _2,
                  midori: _2,
                  minakami: _2,
                  naganohara: _2,
                  nakanojo: _2,
                  nanmoku: _2,
                  numata: _2,
                  oizumi: _2,
                  ora: _2,
                  ota: _2,
                  shibukawa: _2,
                  shimonita: _2,
                  shinto: _2,
                  showa: _2,
                  takasaki: _2,
                  takayama: _2,
                  tamamura: _2,
                  tatebayashi: _2,
                  tomioka: _2,
                  tsukiyono: _2,
                  tsumagoi: _2,
                  ueno: _2,
                  yoshioka: _2,
                },
              ],
              hiroshima: [
                1,
                {
                  asaminami: _2,
                  daiwa: _2,
                  etajima: _2,
                  fuchu: _2,
                  fukuyama: _2,
                  hatsukaichi: _2,
                  higashihiroshima: _2,
                  hongo: _2,
                  jinsekikogen: _2,
                  kaita: _2,
                  kui: _2,
                  kumano: _2,
                  kure: _2,
                  mihara: _2,
                  miyoshi: _2,
                  naka: _2,
                  onomichi: _2,
                  osakikamijima: _2,
                  otake: _2,
                  saka: _2,
                  sera: _2,
                  seranishi: _2,
                  shinichi: _2,
                  shobara: _2,
                  takehara: _2,
                },
              ],
              hokkaido: [
                1,
                {
                  abashiri: _2,
                  abira: _2,
                  aibetsu: _2,
                  akabira: _2,
                  akkeshi: _2,
                  asahikawa: _2,
                  ashibetsu: _2,
                  ashoro: _2,
                  assabu: _2,
                  atsuma: _2,
                  bibai: _2,
                  biei: _2,
                  bifuka: _2,
                  bihoro: _2,
                  biratori: _2,
                  chippubetsu: _2,
                  chitose: _2,
                  date: _2,
                  ebetsu: _2,
                  embetsu: _2,
                  eniwa: _2,
                  erimo: _2,
                  esan: _2,
                  esashi: _2,
                  fukagawa: _2,
                  fukushima: _2,
                  furano: _2,
                  furubira: _2,
                  haboro: _2,
                  hakodate: _2,
                  hamatonbetsu: _2,
                  hidaka: _2,
                  higashikagura: _2,
                  higashikawa: _2,
                  hiroo: _2,
                  hokuryu: _2,
                  hokuto: _2,
                  honbetsu: _2,
                  horokanai: _2,
                  horonobe: _2,
                  ikeda: _2,
                  imakane: _2,
                  ishikari: _2,
                  iwamizawa: _2,
                  iwanai: _2,
                  kamifurano: _2,
                  kamikawa: _2,
                  kamishihoro: _2,
                  kamisunagawa: _2,
                  kamoenai: _2,
                  kayabe: _2,
                  kembuchi: _2,
                  kikonai: _2,
                  kimobetsu: _2,
                  kitahiroshima: _2,
                  kitami: _2,
                  kiyosato: _2,
                  koshimizu: _2,
                  kunneppu: _2,
                  kuriyama: _2,
                  kuromatsunai: _2,
                  kushiro: _2,
                  kutchan: _2,
                  kyowa: _2,
                  mashike: _2,
                  matsumae: _2,
                  mikasa: _2,
                  minamifurano: _2,
                  mombetsu: _2,
                  moseushi: _2,
                  mukawa: _2,
                  muroran: _2,
                  naie: _2,
                  nakagawa: _2,
                  nakasatsunai: _2,
                  nakatombetsu: _2,
                  nanae: _2,
                  nanporo: _2,
                  nayoro: _2,
                  nemuro: _2,
                  niikappu: _2,
                  niki: _2,
                  nishiokoppe: _2,
                  noboribetsu: _2,
                  numata: _2,
                  obihiro: _2,
                  obira: _2,
                  oketo: _2,
                  okoppe: _2,
                  otaru: _2,
                  otobe: _2,
                  otofuke: _2,
                  otoineppu: _2,
                  oumu: _2,
                  ozora: _2,
                  pippu: _2,
                  rankoshi: _2,
                  rebun: _2,
                  rikubetsu: _2,
                  rishiri: _2,
                  rishirifuji: _2,
                  saroma: _2,
                  sarufutsu: _2,
                  shakotan: _2,
                  shari: _2,
                  shibecha: _2,
                  shibetsu: _2,
                  shikabe: _2,
                  shikaoi: _2,
                  shimamaki: _2,
                  shimizu: _2,
                  shimokawa: _2,
                  shinshinotsu: _2,
                  shintoku: _2,
                  shiranuka: _2,
                  shiraoi: _2,
                  shiriuchi: _2,
                  sobetsu: _2,
                  sunagawa: _2,
                  taiki: _2,
                  takasu: _2,
                  takikawa: _2,
                  takinoue: _2,
                  teshikaga: _2,
                  tobetsu: _2,
                  tohma: _2,
                  tomakomai: _2,
                  tomari: _2,
                  toya: _2,
                  toyako: _2,
                  toyotomi: _2,
                  toyoura: _2,
                  tsubetsu: _2,
                  tsukigata: _2,
                  urakawa: _2,
                  urausu: _2,
                  uryu: _2,
                  utashinai: _2,
                  wakkanai: _2,
                  wassamu: _2,
                  yakumo: _2,
                  yoichi: _2,
                },
              ],
              hyogo: [
                1,
                {
                  aioi: _2,
                  akashi: _2,
                  ako: _2,
                  amagasaki: _2,
                  aogaki: _2,
                  asago: _2,
                  ashiya: _2,
                  awaji: _2,
                  fukusaki: _2,
                  goshiki: _2,
                  harima: _2,
                  himeji: _2,
                  ichikawa: _2,
                  inagawa: _2,
                  itami: _2,
                  kakogawa: _2,
                  kamigori: _2,
                  kamikawa: _2,
                  kasai: _2,
                  kasuga: _2,
                  kawanishi: _2,
                  miki: _2,
                  minamiawaji: _2,
                  nishinomiya: _2,
                  nishiwaki: _2,
                  ono: _2,
                  sanda: _2,
                  sannan: _2,
                  sasayama: _2,
                  sayo: _2,
                  shingu: _2,
                  shinonsen: _2,
                  shiso: _2,
                  sumoto: _2,
                  taishi: _2,
                  taka: _2,
                  takarazuka: _2,
                  takasago: _2,
                  takino: _2,
                  tamba: _2,
                  tatsuno: _2,
                  toyooka: _2,
                  yabu: _2,
                  yashiro: _2,
                  yoka: _2,
                  yokawa: _2,
                },
              ],
              ibaraki: [
                1,
                {
                  ami: _2,
                  asahi: _2,
                  bando: _2,
                  chikusei: _2,
                  daigo: _2,
                  fujishiro: _2,
                  hitachi: _2,
                  hitachinaka: _2,
                  hitachiomiya: _2,
                  hitachiota: _2,
                  ibaraki: _2,
                  ina: _2,
                  inashiki: _2,
                  itako: _2,
                  iwama: _2,
                  joso: _2,
                  kamisu: _2,
                  kasama: _2,
                  kashima: _2,
                  kasumigaura: _2,
                  koga: _2,
                  miho: _2,
                  mito: _2,
                  moriya: _2,
                  naka: _2,
                  namegata: _2,
                  oarai: _2,
                  ogawa: _2,
                  omitama: _2,
                  ryugasaki: _2,
                  sakai: _2,
                  sakuragawa: _2,
                  shimodate: _2,
                  shimotsuma: _2,
                  shirosato: _2,
                  sowa: _2,
                  suifu: _2,
                  takahagi: _2,
                  tamatsukuri: _2,
                  tokai: _2,
                  tomobe: _2,
                  tone: _2,
                  toride: _2,
                  tsuchiura: _2,
                  tsukuba: _2,
                  uchihara: _2,
                  ushiku: _2,
                  yachiyo: _2,
                  yamagata: _2,
                  yawara: _2,
                  yuki: _2,
                },
              ],
              ishikawa: [
                1,
                {
                  anamizu: _2,
                  hakui: _2,
                  hakusan: _2,
                  kaga: _2,
                  kahoku: _2,
                  kanazawa: _2,
                  kawakita: _2,
                  komatsu: _2,
                  nakanoto: _2,
                  nanao: _2,
                  nomi: _2,
                  nonoichi: _2,
                  noto: _2,
                  shika: _2,
                  suzu: _2,
                  tsubata: _2,
                  tsurugi: _2,
                  uchinada: _2,
                  wajima: _2,
                },
              ],
              iwate: [
                1,
                {
                  fudai: _2,
                  fujisawa: _2,
                  hanamaki: _2,
                  hiraizumi: _2,
                  hirono: _2,
                  ichinohe: _2,
                  ichinoseki: _2,
                  iwaizumi: _2,
                  iwate: _2,
                  joboji: _2,
                  kamaishi: _2,
                  kanegasaki: _2,
                  karumai: _2,
                  kawai: _2,
                  kitakami: _2,
                  kuji: _2,
                  kunohe: _2,
                  kuzumaki: _2,
                  miyako: _2,
                  mizusawa: _2,
                  morioka: _2,
                  ninohe: _2,
                  noda: _2,
                  ofunato: _2,
                  oshu: _2,
                  otsuchi: _2,
                  rikuzentakata: _2,
                  shiwa: _2,
                  shizukuishi: _2,
                  sumita: _2,
                  tanohata: _2,
                  tono: _2,
                  yahaba: _2,
                  yamada: _2,
                },
              ],
              kagawa: [
                1,
                {
                  ayagawa: _2,
                  higashikagawa: _2,
                  kanonji: _2,
                  kotohira: _2,
                  manno: _2,
                  marugame: _2,
                  mitoyo: _2,
                  naoshima: _2,
                  sanuki: _2,
                  tadotsu: _2,
                  takamatsu: _2,
                  tonosho: _2,
                  uchinomi: _2,
                  utazu: _2,
                  zentsuji: _2,
                },
              ],
              kagoshima: [
                1,
                {
                  akune: _2,
                  amami: _2,
                  hioki: _2,
                  isa: _2,
                  isen: _2,
                  izumi: _2,
                  kagoshima: _2,
                  kanoya: _2,
                  kawanabe: _2,
                  kinko: _2,
                  kouyama: _2,
                  makurazaki: _2,
                  matsumoto: _2,
                  minamitane: _2,
                  nakatane: _2,
                  nishinoomote: _2,
                  satsumasendai: _2,
                  soo: _2,
                  tarumizu: _2,
                  yusui: _2,
                },
              ],
              kanagawa: [
                1,
                {
                  aikawa: _2,
                  atsugi: _2,
                  ayase: _2,
                  chigasaki: _2,
                  ebina: _2,
                  fujisawa: _2,
                  hadano: _2,
                  hakone: _2,
                  hiratsuka: _2,
                  isehara: _2,
                  kaisei: _2,
                  kamakura: _2,
                  kiyokawa: _2,
                  matsuda: _2,
                  minamiashigara: _2,
                  miura: _2,
                  nakai: _2,
                  ninomiya: _2,
                  odawara: _2,
                  oi: _2,
                  oiso: _2,
                  sagamihara: _2,
                  samukawa: _2,
                  tsukui: _2,
                  yamakita: _2,
                  yamato: _2,
                  yokosuka: _2,
                  yugawara: _2,
                  zama: _2,
                  zushi: _2,
                },
              ],
              kochi: [
                1,
                {
                  aki: _2,
                  geisei: _2,
                  hidaka: _2,
                  higashitsuno: _2,
                  ino: _2,
                  kagami: _2,
                  kami: _2,
                  kitagawa: _2,
                  kochi: _2,
                  mihara: _2,
                  motoyama: _2,
                  muroto: _2,
                  nahari: _2,
                  nakamura: _2,
                  nankoku: _2,
                  nishitosa: _2,
                  niyodogawa: _2,
                  ochi: _2,
                  okawa: _2,
                  otoyo: _2,
                  otsuki: _2,
                  sakawa: _2,
                  sukumo: _2,
                  susaki: _2,
                  tosa: _2,
                  tosashimizu: _2,
                  toyo: _2,
                  tsuno: _2,
                  umaji: _2,
                  yasuda: _2,
                  yusuhara: _2,
                },
              ],
              kumamoto: [
                1,
                {
                  amakusa: _2,
                  arao: _2,
                  aso: _2,
                  choyo: _2,
                  gyokuto: _2,
                  kamiamakusa: _2,
                  kikuchi: _2,
                  kumamoto: _2,
                  mashiki: _2,
                  mifune: _2,
                  minamata: _2,
                  minamioguni: _2,
                  nagasu: _2,
                  nishihara: _2,
                  oguni: _2,
                  ozu: _2,
                  sumoto: _2,
                  takamori: _2,
                  uki: _2,
                  uto: _2,
                  yamaga: _2,
                  yamato: _2,
                  yatsushiro: _2,
                },
              ],
              kyoto: [
                1,
                {
                  ayabe: _2,
                  fukuchiyama: _2,
                  higashiyama: _2,
                  ide: _2,
                  ine: _2,
                  joyo: _2,
                  kameoka: _2,
                  kamo: _2,
                  kita: _2,
                  kizu: _2,
                  kumiyama: _2,
                  kyotamba: _2,
                  kyotanabe: _2,
                  kyotango: _2,
                  maizuru: _2,
                  minami: _2,
                  minamiyamashiro: _2,
                  miyazu: _2,
                  muko: _2,
                  nagaokakyo: _2,
                  nakagyo: _2,
                  nantan: _2,
                  oyamazaki: _2,
                  sakyo: _2,
                  seika: _2,
                  tanabe: _2,
                  uji: _2,
                  ujitawara: _2,
                  wazuka: _2,
                  yamashina: _2,
                  yawata: _2,
                },
              ],
              mie: [
                1,
                {
                  asahi: _2,
                  inabe: _2,
                  ise: _2,
                  kameyama: _2,
                  kawagoe: _2,
                  kiho: _2,
                  kisosaki: _2,
                  kiwa: _2,
                  komono: _2,
                  kumano: _2,
                  kuwana: _2,
                  matsusaka: _2,
                  meiwa: _2,
                  mihama: _2,
                  minamiise: _2,
                  misugi: _2,
                  miyama: _2,
                  nabari: _2,
                  shima: _2,
                  suzuka: _2,
                  tado: _2,
                  taiki: _2,
                  taki: _2,
                  tamaki: _2,
                  toba: _2,
                  tsu: _2,
                  udono: _2,
                  ureshino: _2,
                  watarai: _2,
                  yokkaichi: _2,
                },
              ],
              miyagi: [
                1,
                {
                  furukawa: _2,
                  higashimatsushima: _2,
                  ishinomaki: _2,
                  iwanuma: _2,
                  kakuda: _2,
                  kami: _2,
                  kawasaki: _2,
                  marumori: _2,
                  matsushima: _2,
                  minamisanriku: _2,
                  misato: _2,
                  murata: _2,
                  natori: _2,
                  ogawara: _2,
                  ohira: _2,
                  onagawa: _2,
                  osaki: _2,
                  rifu: _2,
                  semine: _2,
                  shibata: _2,
                  shichikashuku: _2,
                  shikama: _2,
                  shiogama: _2,
                  shiroishi: _2,
                  tagajo: _2,
                  taiwa: _2,
                  tome: _2,
                  tomiya: _2,
                  wakuya: _2,
                  watari: _2,
                  yamamoto: _2,
                  zao: _2,
                },
              ],
              miyazaki: [
                1,
                {
                  aya: _2,
                  ebino: _2,
                  gokase: _2,
                  hyuga: _2,
                  kadogawa: _2,
                  kawaminami: _2,
                  kijo: _2,
                  kitagawa: _2,
                  kitakata: _2,
                  kitaura: _2,
                  kobayashi: _2,
                  kunitomi: _2,
                  kushima: _2,
                  mimata: _2,
                  miyakonojo: _2,
                  miyazaki: _2,
                  morotsuka: _2,
                  nichinan: _2,
                  nishimera: _2,
                  nobeoka: _2,
                  saito: _2,
                  shiiba: _2,
                  shintomi: _2,
                  takaharu: _2,
                  takanabe: _2,
                  takazaki: _2,
                  tsuno: _2,
                },
              ],
              nagano: [
                1,
                {
                  achi: _2,
                  agematsu: _2,
                  anan: _2,
                  aoki: _2,
                  asahi: _2,
                  azumino: _2,
                  chikuhoku: _2,
                  chikuma: _2,
                  chino: _2,
                  fujimi: _2,
                  hakuba: _2,
                  hara: _2,
                  hiraya: _2,
                  iida: _2,
                  iijima: _2,
                  iiyama: _2,
                  iizuna: _2,
                  ikeda: _2,
                  ikusaka: _2,
                  ina: _2,
                  karuizawa: _2,
                  kawakami: _2,
                  kiso: _2,
                  kisofukushima: _2,
                  kitaaiki: _2,
                  komagane: _2,
                  komoro: _2,
                  matsukawa: _2,
                  matsumoto: _2,
                  miasa: _2,
                  minamiaiki: _2,
                  minamimaki: _2,
                  minamiminowa: _2,
                  minowa: _2,
                  miyada: _2,
                  miyota: _2,
                  mochizuki: _2,
                  nagano: _2,
                  nagawa: _2,
                  nagiso: _2,
                  nakagawa: _2,
                  nakano: _2,
                  nozawaonsen: _2,
                  obuse: _2,
                  ogawa: _2,
                  okaya: _2,
                  omachi: _2,
                  omi: _2,
                  ookuwa: _2,
                  ooshika: _2,
                  otaki: _2,
                  otari: _2,
                  sakae: _2,
                  sakaki: _2,
                  saku: _2,
                  sakuho: _2,
                  shimosuwa: _2,
                  shinanomachi: _2,
                  shiojiri: _2,
                  suwa: _2,
                  suzaka: _2,
                  takagi: _2,
                  takamori: _2,
                  takayama: _2,
                  tateshina: _2,
                  tatsuno: _2,
                  togakushi: _2,
                  togura: _2,
                  tomi: _2,
                  ueda: _2,
                  wada: _2,
                  yamagata: _2,
                  yamanouchi: _2,
                  yasaka: _2,
                  yasuoka: _2,
                },
              ],
              nagasaki: [
                1,
                {
                  chijiwa: _2,
                  futsu: _2,
                  goto: _2,
                  hasami: _2,
                  hirado: _2,
                  iki: _2,
                  isahaya: _2,
                  kawatana: _2,
                  kuchinotsu: _2,
                  matsuura: _2,
                  nagasaki: _2,
                  obama: _2,
                  omura: _2,
                  oseto: _2,
                  saikai: _2,
                  sasebo: _2,
                  seihi: _2,
                  shimabara: _2,
                  shinkamigoto: _2,
                  togitsu: _2,
                  tsushima: _2,
                  unzen: _2,
                },
              ],
              nara: [
                1,
                {
                  ando: _2,
                  gose: _2,
                  heguri: _2,
                  higashiyoshino: _2,
                  ikaruga: _2,
                  ikoma: _2,
                  kamikitayama: _2,
                  kanmaki: _2,
                  kashiba: _2,
                  kashihara: _2,
                  katsuragi: _2,
                  kawai: _2,
                  kawakami: _2,
                  kawanishi: _2,
                  koryo: _2,
                  kurotaki: _2,
                  mitsue: _2,
                  miyake: _2,
                  nara: _2,
                  nosegawa: _2,
                  oji: _2,
                  ouda: _2,
                  oyodo: _2,
                  sakurai: _2,
                  sango: _2,
                  shimoichi: _2,
                  shimokitayama: _2,
                  shinjo: _2,
                  soni: _2,
                  takatori: _2,
                  tawaramoto: _2,
                  tenkawa: _2,
                  tenri: _2,
                  uda: _2,
                  yamatokoriyama: _2,
                  yamatotakada: _2,
                  yamazoe: _2,
                  yoshino: _2,
                },
              ],
              niigata: [
                1,
                {
                  aga: _2,
                  agano: _2,
                  gosen: _2,
                  itoigawa: _2,
                  izumozaki: _2,
                  joetsu: _2,
                  kamo: _2,
                  kariwa: _2,
                  kashiwazaki: _2,
                  minamiuonuma: _2,
                  mitsuke: _2,
                  muika: _2,
                  murakami: _2,
                  myoko: _2,
                  nagaoka: _2,
                  niigata: _2,
                  ojiya: _2,
                  omi: _2,
                  sado: _2,
                  sanjo: _2,
                  seiro: _2,
                  seirou: _2,
                  sekikawa: _2,
                  shibata: _2,
                  tagami: _2,
                  tainai: _2,
                  tochio: _2,
                  tokamachi: _2,
                  tsubame: _2,
                  tsunan: _2,
                  uonuma: _2,
                  yahiko: _2,
                  yoita: _2,
                  yuzawa: _2,
                },
              ],
              oita: [
                1,
                {
                  beppu: _2,
                  bungoono: _2,
                  bungotakada: _2,
                  hasama: _2,
                  hiji: _2,
                  himeshima: _2,
                  hita: _2,
                  kamitsue: _2,
                  kokonoe: _2,
                  kuju: _2,
                  kunisaki: _2,
                  kusu: _2,
                  oita: _2,
                  saiki: _2,
                  taketa: _2,
                  tsukumi: _2,
                  usa: _2,
                  usuki: _2,
                  yufu: _2,
                },
              ],
              okayama: [
                1,
                {
                  akaiwa: _2,
                  asakuchi: _2,
                  bizen: _2,
                  hayashima: _2,
                  ibara: _2,
                  kagamino: _2,
                  kasaoka: _2,
                  kibichuo: _2,
                  kumenan: _2,
                  kurashiki: _2,
                  maniwa: _2,
                  misaki: _2,
                  nagi: _2,
                  niimi: _2,
                  nishiawakura: _2,
                  okayama: _2,
                  satosho: _2,
                  setouchi: _2,
                  shinjo: _2,
                  shoo: _2,
                  soja: _2,
                  takahashi: _2,
                  tamano: _2,
                  tsuyama: _2,
                  wake: _2,
                  yakage: _2,
                },
              ],
              okinawa: [
                1,
                {
                  aguni: _2,
                  ginowan: _2,
                  ginoza: _2,
                  gushikami: _2,
                  haebaru: _2,
                  higashi: _2,
                  hirara: _2,
                  iheya: _2,
                  ishigaki: _2,
                  ishikawa: _2,
                  itoman: _2,
                  izena: _2,
                  kadena: _2,
                  kin: _2,
                  kitadaito: _2,
                  kitanakagusuku: _2,
                  kumejima: _2,
                  kunigami: _2,
                  minamidaito: _2,
                  motobu: _2,
                  nago: _2,
                  naha: _2,
                  nakagusuku: _2,
                  nakijin: _2,
                  nanjo: _2,
                  nishihara: _2,
                  ogimi: _2,
                  okinawa: _2,
                  onna: _2,
                  shimoji: _2,
                  taketomi: _2,
                  tarama: _2,
                  tokashiki: _2,
                  tomigusuku: _2,
                  tonaki: _2,
                  urasoe: _2,
                  uruma: _2,
                  yaese: _2,
                  yomitan: _2,
                  yonabaru: _2,
                  yonaguni: _2,
                  zamami: _2,
                },
              ],
              osaka: [
                1,
                {
                  abeno: _2,
                  chihayaakasaka: _2,
                  chuo: _2,
                  daito: _2,
                  fujiidera: _2,
                  habikino: _2,
                  hannan: _2,
                  higashiosaka: _2,
                  higashisumiyoshi: _2,
                  higashiyodogawa: _2,
                  hirakata: _2,
                  ibaraki: _2,
                  ikeda: _2,
                  izumi: _2,
                  izumiotsu: _2,
                  izumisano: _2,
                  kadoma: _2,
                  kaizuka: _2,
                  kanan: _2,
                  kashiwara: _2,
                  katano: _2,
                  kawachinagano: _2,
                  kishiwada: _2,
                  kita: _2,
                  kumatori: _2,
                  matsubara: _2,
                  minato: _2,
                  minoh: _2,
                  misaki: _2,
                  moriguchi: _2,
                  neyagawa: _2,
                  nishi: _2,
                  nose: _2,
                  osakasayama: _2,
                  sakai: _2,
                  sayama: _2,
                  sennan: _2,
                  settsu: _2,
                  shijonawate: _2,
                  shimamoto: _2,
                  suita: _2,
                  tadaoka: _2,
                  taishi: _2,
                  tajiri: _2,
                  takaishi: _2,
                  takatsuki: _2,
                  tondabayashi: _2,
                  toyonaka: _2,
                  toyono: _2,
                  yao: _2,
                },
              ],
              saga: [
                1,
                {
                  ariake: _2,
                  arita: _2,
                  fukudomi: _2,
                  genkai: _2,
                  hamatama: _2,
                  hizen: _2,
                  imari: _2,
                  kamimine: _2,
                  kanzaki: _2,
                  karatsu: _2,
                  kashima: _2,
                  kitagata: _2,
                  kitahata: _2,
                  kiyama: _2,
                  kouhoku: _2,
                  kyuragi: _2,
                  nishiarita: _2,
                  ogi: _2,
                  omachi: _2,
                  ouchi: _2,
                  saga: _2,
                  shiroishi: _2,
                  taku: _2,
                  tara: _2,
                  tosu: _2,
                  yoshinogari: _2,
                },
              ],
              saitama: [
                1,
                {
                  arakawa: _2,
                  asaka: _2,
                  chichibu: _2,
                  fujimi: _2,
                  fujimino: _2,
                  fukaya: _2,
                  hanno: _2,
                  hanyu: _2,
                  hasuda: _2,
                  hatogaya: _2,
                  hatoyama: _2,
                  hidaka: _2,
                  higashichichibu: _2,
                  higashimatsuyama: _2,
                  honjo: _2,
                  ina: _2,
                  iruma: _2,
                  iwatsuki: _2,
                  kamiizumi: _2,
                  kamikawa: _2,
                  kamisato: _2,
                  kasukabe: _2,
                  kawagoe: _2,
                  kawaguchi: _2,
                  kawajima: _2,
                  kazo: _2,
                  kitamoto: _2,
                  koshigaya: _2,
                  kounosu: _2,
                  kuki: _2,
                  kumagaya: _2,
                  matsubushi: _2,
                  minano: _2,
                  misato: _2,
                  miyashiro: _2,
                  miyoshi: _2,
                  moroyama: _2,
                  nagatoro: _2,
                  namegawa: _2,
                  niiza: _2,
                  ogano: _2,
                  ogawa: _2,
                  ogose: _2,
                  okegawa: _2,
                  omiya: _2,
                  otaki: _2,
                  ranzan: _2,
                  ryokami: _2,
                  saitama: _2,
                  sakado: _2,
                  satte: _2,
                  sayama: _2,
                  shiki: _2,
                  shiraoka: _2,
                  soka: _2,
                  sugito: _2,
                  toda: _2,
                  tokigawa: _2,
                  tokorozawa: _2,
                  tsurugashima: _2,
                  urawa: _2,
                  warabi: _2,
                  yashio: _2,
                  yokoze: _2,
                  yono: _2,
                  yorii: _2,
                  yoshida: _2,
                  yoshikawa: _2,
                  yoshimi: _2,
                },
              ],
              shiga: [
                1,
                {
                  aisho: _2,
                  gamo: _2,
                  higashiomi: _2,
                  hikone: _2,
                  koka: _2,
                  konan: _2,
                  kosei: _2,
                  koto: _2,
                  kusatsu: _2,
                  maibara: _2,
                  moriyama: _2,
                  nagahama: _2,
                  nishiazai: _2,
                  notogawa: _2,
                  omihachiman: _2,
                  otsu: _2,
                  ritto: _2,
                  ryuoh: _2,
                  takashima: _2,
                  takatsuki: _2,
                  torahime: _2,
                  toyosato: _2,
                  yasu: _2,
                },
              ],
              shimane: [
                1,
                {
                  akagi: _2,
                  ama: _2,
                  gotsu: _2,
                  hamada: _2,
                  higashiizumo: _2,
                  hikawa: _2,
                  hikimi: _2,
                  izumo: _2,
                  kakinoki: _2,
                  masuda: _2,
                  matsue: _2,
                  misato: _2,
                  nishinoshima: _2,
                  ohda: _2,
                  okinoshima: _2,
                  okuizumo: _2,
                  shimane: _2,
                  tamayu: _2,
                  tsuwano: _2,
                  unnan: _2,
                  yakumo: _2,
                  yasugi: _2,
                  yatsuka: _2,
                },
              ],
              shizuoka: [
                1,
                {
                  arai: _2,
                  atami: _2,
                  fuji: _2,
                  fujieda: _2,
                  fujikawa: _2,
                  fujinomiya: _2,
                  fukuroi: _2,
                  gotemba: _2,
                  haibara: _2,
                  hamamatsu: _2,
                  higashiizu: _2,
                  ito: _2,
                  iwata: _2,
                  izu: _2,
                  izunokuni: _2,
                  kakegawa: _2,
                  kannami: _2,
                  kawanehon: _2,
                  kawazu: _2,
                  kikugawa: _2,
                  kosai: _2,
                  makinohara: _2,
                  matsuzaki: _2,
                  minamiizu: _2,
                  mishima: _2,
                  morimachi: _2,
                  nishiizu: _2,
                  numazu: _2,
                  omaezaki: _2,
                  shimada: _2,
                  shimizu: _2,
                  shimoda: _2,
                  shizuoka: _2,
                  susono: _2,
                  yaizu: _2,
                  yoshida: _2,
                },
              ],
              tochigi: [
                1,
                {
                  ashikaga: _2,
                  bato: _2,
                  haga: _2,
                  ichikai: _2,
                  iwafune: _2,
                  kaminokawa: _2,
                  kanuma: _2,
                  karasuyama: _2,
                  kuroiso: _2,
                  mashiko: _2,
                  mibu: _2,
                  moka: _2,
                  motegi: _2,
                  nasu: _2,
                  nasushiobara: _2,
                  nikko: _2,
                  nishikata: _2,
                  nogi: _2,
                  ohira: _2,
                  ohtawara: _2,
                  oyama: _2,
                  sakura: _2,
                  sano: _2,
                  shimotsuke: _2,
                  shioya: _2,
                  takanezawa: _2,
                  tochigi: _2,
                  tsuga: _2,
                  ujiie: _2,
                  utsunomiya: _2,
                  yaita: _2,
                },
              ],
              tokushima: [
                1,
                {
                  aizumi: _2,
                  anan: _2,
                  ichiba: _2,
                  itano: _2,
                  kainan: _2,
                  komatsushima: _2,
                  matsushige: _2,
                  mima: _2,
                  minami: _2,
                  miyoshi: _2,
                  mugi: _2,
                  nakagawa: _2,
                  naruto: _2,
                  sanagochi: _2,
                  shishikui: _2,
                  tokushima: _2,
                  wajiki: _2,
                },
              ],
              tokyo: [
                1,
                {
                  adachi: _2,
                  akiruno: _2,
                  akishima: _2,
                  aogashima: _2,
                  arakawa: _2,
                  bunkyo: _2,
                  chiyoda: _2,
                  chofu: _2,
                  chuo: _2,
                  edogawa: _2,
                  fuchu: _2,
                  fussa: _2,
                  hachijo: _2,
                  hachioji: _2,
                  hamura: _2,
                  higashikurume: _2,
                  higashimurayama: _2,
                  higashiyamato: _2,
                  hino: _2,
                  hinode: _2,
                  hinohara: _2,
                  inagi: _2,
                  itabashi: _2,
                  katsushika: _2,
                  kita: _2,
                  kiyose: _2,
                  kodaira: _2,
                  koganei: _2,
                  kokubunji: _2,
                  komae: _2,
                  koto: _2,
                  kouzushima: _2,
                  kunitachi: _2,
                  machida: _2,
                  meguro: _2,
                  minato: _2,
                  mitaka: _2,
                  mizuho: _2,
                  musashimurayama: _2,
                  musashino: _2,
                  nakano: _2,
                  nerima: _2,
                  ogasawara: _2,
                  okutama: _2,
                  ome: _2,
                  oshima: _2,
                  ota: _2,
                  setagaya: _2,
                  shibuya: _2,
                  shinagawa: _2,
                  shinjuku: _2,
                  suginami: _2,
                  sumida: _2,
                  tachikawa: _2,
                  taito: _2,
                  tama: _2,
                  toshima: _2,
                },
              ],
              tottori: [
                1,
                {
                  chizu: _2,
                  hino: _2,
                  kawahara: _2,
                  koge: _2,
                  kotoura: _2,
                  misasa: _2,
                  nanbu: _2,
                  nichinan: _2,
                  sakaiminato: _2,
                  tottori: _2,
                  wakasa: _2,
                  yazu: _2,
                  yonago: _2,
                },
              ],
              toyama: [
                1,
                {
                  asahi: _2,
                  fuchu: _2,
                  fukumitsu: _2,
                  funahashi: _2,
                  himi: _2,
                  imizu: _2,
                  inami: _2,
                  johana: _2,
                  kamiichi: _2,
                  kurobe: _2,
                  nakaniikawa: _2,
                  namerikawa: _2,
                  nanto: _2,
                  nyuzen: _2,
                  oyabe: _2,
                  taira: _2,
                  takaoka: _2,
                  tateyama: _2,
                  toga: _2,
                  tonami: _2,
                  toyama: _2,
                  unazuki: _2,
                  uozu: _2,
                  yamada: _2,
                },
              ],
              wakayama: [
                1,
                {
                  arida: _2,
                  aridagawa: _2,
                  gobo: _2,
                  hashimoto: _2,
                  hidaka: _2,
                  hirogawa: _2,
                  inami: _2,
                  iwade: _2,
                  kainan: _2,
                  kamitonda: _2,
                  katsuragi: _2,
                  kimino: _2,
                  kinokawa: _2,
                  kitayama: _2,
                  koya: _2,
                  koza: _2,
                  kozagawa: _2,
                  kudoyama: _2,
                  kushimoto: _2,
                  mihama: _2,
                  misato: _2,
                  nachikatsuura: _2,
                  shingu: _2,
                  shirahama: _2,
                  taiji: _2,
                  tanabe: _2,
                  wakayama: _2,
                  yuasa: _2,
                  yura: _2,
                },
              ],
              yamagata: [
                1,
                {
                  asahi: _2,
                  funagata: _2,
                  higashine: _2,
                  iide: _2,
                  kahoku: _2,
                  kaminoyama: _2,
                  kaneyama: _2,
                  kawanishi: _2,
                  mamurogawa: _2,
                  mikawa: _2,
                  murayama: _2,
                  nagai: _2,
                  nakayama: _2,
                  nanyo: _2,
                  nishikawa: _2,
                  obanazawa: _2,
                  oe: _2,
                  oguni: _2,
                  ohkura: _2,
                  oishida: _2,
                  sagae: _2,
                  sakata: _2,
                  sakegawa: _2,
                  shinjo: _2,
                  shirataka: _2,
                  shonai: _2,
                  takahata: _2,
                  tendo: _2,
                  tozawa: _2,
                  tsuruoka: _2,
                  yamagata: _2,
                  yamanobe: _2,
                  yonezawa: _2,
                  yuza: _2,
                },
              ],
              yamaguchi: [
                1,
                {
                  abu: _2,
                  hagi: _2,
                  hikari: _2,
                  hofu: _2,
                  iwakuni: _2,
                  kudamatsu: _2,
                  mitou: _2,
                  nagato: _2,
                  oshima: _2,
                  shimonoseki: _2,
                  shunan: _2,
                  tabuse: _2,
                  tokuyama: _2,
                  toyota: _2,
                  ube: _2,
                  yuu: _2,
                },
              ],
              yamanashi: [
                1,
                {
                  chuo: _2,
                  doshi: _2,
                  fuefuki: _2,
                  fujikawa: _2,
                  fujikawaguchiko: _2,
                  fujiyoshida: _2,
                  hayakawa: _2,
                  hokuto: _2,
                  ichikawamisato: _2,
                  kai: _2,
                  kofu: _2,
                  koshu: _2,
                  kosuge: _2,
                  "minami-alps": _2,
                  minobu: _2,
                  nakamichi: _2,
                  nanbu: _2,
                  narusawa: _2,
                  nirasaki: _2,
                  nishikatsura: _2,
                  oshino: _2,
                  otsuki: _2,
                  showa: _2,
                  tabayama: _2,
                  tsuru: _2,
                  uenohara: _2,
                  yamanakako: _2,
                  yamanashi: _2,
                },
              ],
              "xn--4pvxs": _2,
              栃木: _2,
              "xn--vgu402c": _2,
              愛知: _2,
              "xn--c3s14m": _2,
              愛媛: _2,
              "xn--f6qx53a": _2,
              兵庫: _2,
              "xn--8pvr4u": _2,
              熊本: _2,
              "xn--uist22h": _2,
              茨城: _2,
              "xn--djrs72d6uy": _2,
              北海道: _2,
              "xn--mkru45i": _2,
              千葉: _2,
              "xn--0trq7p7nn": _2,
              和歌山: _2,
              "xn--8ltr62k": _2,
              長崎: _2,
              "xn--2m4a15e": _2,
              長野: _2,
              "xn--efvn9s": _2,
              新潟: _2,
              "xn--32vp30h": _2,
              青森: _2,
              "xn--4it797k": _2,
              静岡: _2,
              "xn--1lqs71d": _2,
              東京: _2,
              "xn--5rtp49c": _2,
              石川: _2,
              "xn--5js045d": _2,
              埼玉: _2,
              "xn--ehqz56n": _2,
              三重: _2,
              "xn--1lqs03n": _2,
              京都: _2,
              "xn--qqqt11m": _2,
              佐賀: _2,
              "xn--kbrq7o": _2,
              大分: _2,
              "xn--pssu33l": _2,
              大阪: _2,
              "xn--ntsq17g": _2,
              奈良: _2,
              "xn--uisz3g": _2,
              宮城: _2,
              "xn--6btw5a": _2,
              宮崎: _2,
              "xn--1ctwo": _2,
              富山: _2,
              "xn--6orx2r": _2,
              山口: _2,
              "xn--rht61e": _2,
              山形: _2,
              "xn--rht27z": _2,
              山梨: _2,
              "xn--djty4k": _2,
              岩手: _2,
              "xn--nit225k": _2,
              岐阜: _2,
              "xn--rht3d": _2,
              岡山: _2,
              "xn--klty5x": _2,
              島根: _2,
              "xn--kltx9a": _2,
              広島: _2,
              "xn--kltp7d": _2,
              徳島: _2,
              "xn--uuwu58a": _2,
              沖縄: _2,
              "xn--zbx025d": _2,
              滋賀: _2,
              "xn--ntso0iqx3a": _2,
              神奈川: _2,
              "xn--elqq16h": _2,
              福井: _2,
              "xn--4it168d": _2,
              福岡: _2,
              "xn--klt787d": _2,
              福島: _2,
              "xn--rny31h": _2,
              秋田: _2,
              "xn--7t0a264c": _2,
              群馬: _2,
              "xn--5rtq34k": _2,
              香川: _2,
              "xn--k7yn95e": _2,
              高知: _2,
              "xn--tor131o": _2,
              鳥取: _2,
              "xn--d5qv7z876c": _2,
              鹿児島: _2,
              kawasaki: _8,
              kitakyushu: _8,
              kobe: _8,
              nagoya: _8,
              sapporo: _8,
              sendai: _8,
              yokohama: _8,
              buyshop: _3,
              fashionstore: _3,
              handcrafted: _3,
              kawaiishop: _3,
              supersale: _3,
              theshop: _3,
              usercontent: _3,
              angry: _3,
              babyblue: _3,
              babymilk: _3,
              backdrop: _3,
              bambina: _3,
              bitter: _3,
              blush: _3,
              boo: _3,
              boy: _3,
              boyfriend: _3,
              but: _3,
              candypop: _3,
              capoo: _3,
              catfood: _3,
              cheap: _3,
              chicappa: _3,
              chillout: _3,
              chips: _3,
              chowder: _3,
              chu: _3,
              ciao: _3,
              cocotte: _3,
              coolblog: _3,
              cranky: _3,
              cutegirl: _3,
              daa: _3,
              deca: _3,
              deci: _3,
              digick: _3,
              egoism: _3,
              fakefur: _3,
              fem: _3,
              flier: _3,
              floppy: _3,
              fool: _3,
              frenchkiss: _3,
              girlfriend: _3,
              girly: _3,
              gloomy: _3,
              gonna: _3,
              greater: _3,
              hacca: _3,
              heavy: _3,
              her: _3,
              hiho: _3,
              hippy: _3,
              holy: _3,
              hungry: _3,
              icurus: _3,
              itigo: _3,
              jellybean: _3,
              kikirara: _3,
              kill: _3,
              kilo: _3,
              kuron: _3,
              littlestar: _3,
              lolipopmc: _3,
              lolitapunk: _3,
              lomo: _3,
              lovepop: _3,
              lovesick: _3,
              main: _3,
              mods: _3,
              mond: _3,
              mongolian: _3,
              moo: _3,
              namaste: _3,
              nikita: _3,
              nobushi: _3,
              noor: _3,
              oops: _3,
              parallel: _3,
              parasite: _3,
              pecori: _3,
              peewee: _3,
              penne: _3,
              pepper: _3,
              perma: _3,
              pigboat: _3,
              pinoko: _3,
              punyu: _3,
              pupu: _3,
              pussycat: _3,
              pya: _3,
              raindrop: _3,
              readymade: _3,
              sadist: _3,
              schoolbus: _3,
              secret: _3,
              staba: _3,
              stripper: _3,
              sub: _3,
              sunnyday: _3,
              thick: _3,
              tonkotsu: _3,
              under: _3,
              upper: _3,
              velvet: _3,
              verse: _3,
              versus: _3,
              vivian: _3,
              watson: _3,
              weblike: _3,
              whitesnow: _3,
              zombie: _3,
              blogspot: _3,
              "2-d": _3,
              bona: _3,
              crap: _3,
              daynight: _3,
              eek: _3,
              flop: _3,
              halfmoon: _3,
              jeez: _3,
              matrix: _3,
              mimoza: _3,
              netgamers: _3,
              nyanta: _3,
              o0o0: _3,
              rdy: _3,
              rgr: _3,
              rulez: _3,
              sakurastorage: [
                0,
                {
                  isk01: _12,
                  isk02: _12,
                },
              ],
              saloon: _3,
              sblo: _3,
              skr: _3,
              tank: _3,
              "uh-oh": _3,
              undo: _3,
              webaccel: [
                0,
                {
                  rs: _3,
                  user: _3,
                },
              ],
              websozai: _3,
              xii: _3,
            },
          ],
          ke: [
            1,
            {
              ac: _2,
              co: _6,
              go: _2,
              info: _2,
              me: _2,
              mobi: _2,
              ne: _2,
              or: _2,
              sc: _2,
            },
          ],
          kg: [
            1,
            {
              org: _2,
              net: _2,
              com: _2,
              edu: _2,
              gov: _2,
              mil: _2,
              blog: _3,
              io: _3,
              jp: _3,
              tv: _3,
              uk: _3,
              us: _3,
            },
          ],
          kh: _8,
          ki: _35,
          km: [
            1,
            {
              org: _2,
              nom: _2,
              gov: _2,
              prd: _2,
              tm: _2,
              edu: _2,
              mil: _2,
              ass: _2,
              com: _2,
              coop: _2,
              asso: _2,
              presse: _2,
              medecin: _2,
              notaires: _2,
              pharmaciens: _2,
              veterinaire: _2,
              gouv: _2,
            },
          ],
          kn: [
            1,
            {
              net: _2,
              org: _2,
              edu: _2,
              gov: _2,
            },
          ],
          kp: [
            1,
            {
              com: _2,
              edu: _2,
              gov: _2,
              org: _2,
              rep: _2,
              tra: _2,
            },
          ],
          kr: [
            1,
            {
              ac: _2,
              co: _2,
              es: _2,
              go: _2,
              hs: _2,
              kg: _2,
              mil: _2,
              ms: _2,
              ne: _2,
              or: _2,
              pe: _2,
              re: _2,
              sc: _2,
              busan: _2,
              chungbuk: _2,
              chungnam: _2,
              daegu: _2,
              daejeon: _2,
              gangwon: _2,
              gwangju: _2,
              gyeongbuk: _2,
              gyeonggi: _2,
              gyeongnam: _2,
              incheon: _2,
              jeju: _2,
              jeonbuk: _2,
              jeonnam: _2,
              seoul: _2,
              ulsan: _2,
              blogspot: _3,
            },
          ],
          kw: [
            1,
            {
              com: _2,
              edu: _2,
              emb: _2,
              gov: _2,
              ind: _2,
              net: _2,
              org: _2,
            },
          ],
          ky: _27,
          kz: [
            1,
            {
              org: _2,
              edu: _2,
              net: _2,
              gov: _2,
              mil: _2,
              com: _2,
              jcloud: _3,
              kazteleport: [
                0,
                {
                  upaas: _3,
                },
              ],
            },
          ],
          la: [
            1,
            {
              int: _2,
              net: _2,
              info: _2,
              edu: _2,
              gov: _2,
              per: _2,
              com: _2,
              org: _2,
              bnr: _3,
              c: _3,
            },
          ],
          lb: _4,
          lc: [
            1,
            {
              com: _2,
              net: _2,
              co: _2,
              org: _2,
              edu: _2,
              gov: _2,
              oy: _3,
            },
          ],
          li: [
            1,
            {
              blogspot: _3,
              caa: _3,
            },
          ],
          lk: [
            1,
            {
              gov: _2,
              sch: _2,
              net: _2,
              int: _2,
              com: _2,
              org: _2,
              edu: _2,
              ngo: _2,
              soc: _2,
              web: _2,
              ltd: _2,
              assn: _2,
              grp: _2,
              hotel: _2,
              ac: _2,
            },
          ],
          lr: _4,
          ls: [
            1,
            {
              ac: _2,
              biz: _2,
              co: _2,
              edu: _2,
              gov: _2,
              info: _2,
              net: _2,
              org: _2,
              sc: _2,
              de: _3,
            },
          ],
          lt: _36,
          lu: [
            1,
            {
              blogspot: _3,
              "123website": _3,
            },
          ],
          lv: [
            1,
            {
              com: _2,
              edu: _2,
              gov: _2,
              org: _2,
              mil: _2,
              id: _2,
              net: _2,
              asn: _2,
              conf: _2,
            },
          ],
          ly: [
            1,
            {
              com: _2,
              net: _2,
              gov: _2,
              plc: _2,
              edu: _2,
              sch: _2,
              med: _2,
              org: _2,
              id: _2,
            },
          ],
          ma: [
            1,
            {
              co: _2,
              net: _2,
              gov: _2,
              org: _2,
              ac: _2,
              press: _2,
            },
          ],
          mc: [
            1,
            {
              tm: _2,
              asso: _2,
            },
          ],
          md: [
            1,
            {
              blogspot: _3,
              at: _3,
              de: _3,
              jp: _3,
              to: _3,
            },
          ],
          me: [
            1,
            {
              co: _2,
              net: _2,
              org: _2,
              edu: _2,
              ac: _2,
              gov: _2,
              its: _2,
              priv: _2,
              c66: _3,
              daplie: [
                2,
                {
                  localhost: _3,
                },
              ],
              edgestack: _3,
              filegear: _3,
              "filegear-au": _3,
              "filegear-de": _3,
              "filegear-gb": _3,
              "filegear-ie": _3,
              "filegear-jp": _3,
              "filegear-sg": _3,
              glitch: _3,
              ravendb: _3,
              lohmus: _3,
              barsy: _3,
              mcpe: _3,
              mcdir: _3,
              soundcast: _3,
              tcp4: _3,
              brasilia: _3,
              ddns: _3,
              dnsfor: _3,
              hopto: _3,
              loginto: _3,
              noip: _3,
              webhop: _3,
              vp4: _3,
              diskstation: _3,
              dscloud: _3,
              i234: _3,
              myds: _3,
              synology: _3,
              transip: _25,
              wedeploy: _3,
              yombo: _3,
              nohost: _3,
            },
          ],
          mg: [
            1,
            {
              org: _2,
              nom: _2,
              gov: _2,
              prd: _2,
              tm: _2,
              edu: _2,
              mil: _2,
              com: _2,
              co: _2,
            },
          ],
          mh: _2,
          mil: _2,
          mk: [
            1,
            {
              com: _2,
              org: _2,
              net: _2,
              edu: _2,
              gov: _2,
              inf: _2,
              name: _2,
              blogspot: _3,
            },
          ],
          ml: [
            1,
            {
              com: _2,
              edu: _2,
              gouv: _2,
              gov: _2,
              net: _2,
              org: _2,
              presse: _2,
            },
          ],
          mm: _8,
          mn: [
            1,
            {
              gov: _2,
              edu: _2,
              org: _2,
              nyc: _3,
            },
          ],
          mo: _4,
          mobi: [
            1,
            {
              barsy: _3,
              dscloud: _3,
            },
          ],
          mp: [
            1,
            {
              ju: _3,
            },
          ],
          mq: _2,
          mr: _36,
          ms: [
            1,
            {
              com: _2,
              edu: _2,
              gov: _2,
              net: _2,
              org: _2,
              lab: _3,
              minisite: _3,
            },
          ],
          mt: [
            1,
            {
              com: _6,
              edu: _2,
              net: _2,
              org: _2,
            },
          ],
          mu: [
            1,
            {
              com: _2,
              net: _2,
              org: _2,
              gov: _2,
              ac: _2,
              co: _2,
              or: _2,
            },
          ],
          museum: _2,
          mv: [
            1,
            {
              aero: _2,
              biz: _2,
              com: _2,
              coop: _2,
              edu: _2,
              gov: _2,
              info: _2,
              int: _2,
              mil: _2,
              museum: _2,
              name: _2,
              net: _2,
              org: _2,
              pro: _2,
            },
          ],
          mw: [
            1,
            {
              ac: _2,
              biz: _2,
              co: _2,
              com: _2,
              coop: _2,
              edu: _2,
              gov: _2,
              int: _2,
              museum: _2,
              net: _2,
              org: _2,
            },
          ],
          mx: [
            1,
            {
              com: _2,
              org: _2,
              gob: _2,
              edu: _2,
              net: _2,
              blogspot: _3,
            },
          ],
          my: [
            1,
            {
              biz: _2,
              com: _2,
              edu: _2,
              gov: _2,
              mil: _2,
              name: _2,
              net: _2,
              org: _2,
              blogspot: _3,
            },
          ],
          mz: [
            1,
            {
              ac: _2,
              adv: _2,
              co: _2,
              edu: _2,
              gov: _2,
              mil: _2,
              net: _2,
              org: _2,
            },
          ],
          na: [
            1,
            {
              info: _2,
              pro: _2,
              name: _2,
              school: _2,
              or: _2,
              dr: _2,
              us: _2,
              mx: _2,
              ca: _2,
              in: _2,
              cc: _2,
              tv: _2,
              ws: _2,
              mobi: _2,
              co: _2,
              com: _2,
              org: _2,
            },
          ],
          name: [
            1,
            {
              her: _39,
              his: _39,
            },
          ],
          nc: [
            1,
            {
              asso: _2,
              nom: _2,
            },
          ],
          ne: _2,
          net: [
            1,
            {
              adobeaemcloud: _3,
              "adobeio-static": _3,
              adobeioruntime: _3,
              akadns: _3,
              akamai: _3,
              "akamai-staging": _3,
              akamaiedge: _3,
              "akamaiedge-staging": _3,
              akamaihd: _3,
              "akamaihd-staging": _3,
              akamaiorigin: _3,
              "akamaiorigin-staging": _3,
              akamaized: _3,
              "akamaized-staging": _3,
              edgekey: _3,
              "edgekey-staging": _3,
              edgesuite: _3,
              "edgesuite-staging": _3,
              alwaysdata: _3,
              myamaze: _3,
              cloudfront: _3,
              t3l3p0rt: _3,
              appudo: _3,
              "atlassian-dev": [
                0,
                {
                  prod: [
                    0,
                    {
                      cdn: _3,
                    },
                  ],
                },
              ],
              myfritz: _3,
              onavstack: _3,
              shopselect: _3,
              blackbaudcdn: _3,
              boomla: _3,
              bplaced: _3,
              square7: _3,
              gb: _3,
              hu: _3,
              jp: _3,
              se: _3,
              uk: _3,
              in: _3,
              clickrising: _3,
              cloudaccess: _3,
              "cdn77-ssl": _3,
              cdn77: [
                0,
                {
                  r: _3,
                },
              ],
              "feste-ip": _3,
              "knx-server": _3,
              "static-access": _3,
              cryptonomic: _5,
              dattolocal: _3,
              mydatto: _3,
              debian: _3,
              bitbridge: _3,
              "at-band-camp": _3,
              blogdns: _3,
              "broke-it": _3,
              buyshouses: _3,
              dnsalias: _3,
              dnsdojo: _3,
              "does-it": _3,
              dontexist: _3,
              dynalias: _3,
              dynathome: _3,
              endofinternet: _3,
              "from-az": _3,
              "from-co": _3,
              "from-la": _3,
              "from-ny": _3,
              "gets-it": _3,
              "ham-radio-op": _3,
              homeftp: _3,
              homeip: _3,
              homelinux: _3,
              homeunix: _3,
              "in-the-band": _3,
              "is-a-chef": _3,
              "is-a-geek": _3,
              "isa-geek": _3,
              "kicks-ass": _3,
              "office-on-the": _3,
              podzone: _3,
              "scrapper-site": _3,
              selfip: _3,
              "sells-it": _3,
              servebbs: _3,
              serveftp: _3,
              thruhere: _3,
              webhop: _3,
              definima: _3,
              casacam: _3,
              dynu: _3,
              dynv6: _3,
              twmail: _3,
              ru: _3,
              channelsdvr: [
                2,
                {
                  u: _3,
                },
              ],
              fastlylb: [
                2,
                {
                  map: _3,
                },
              ],
              fastly: [
                0,
                {
                  freetls: _3,
                  map: _3,
                  prod: [
                    0,
                    {
                      a: _3,
                      global: _3,
                    },
                  ],
                  ssl: [
                    0,
                    {
                      a: _3,
                      b: _3,
                      global: _3,
                    },
                  ],
                },
              ],
              edgeapp: _3,
              flynnhosting: _3,
              "cdn-edges": _3,
              heteml: _3,
              cloudfunctions: _3,
              moonscale: _3,
              "in-dsl": _3,
              "in-vpn": _3,
              ipifony: _3,
              iobb: _3,
              cloudjiffy: [
                2,
                {
                  "fra1-de": _3,
                  "west1-us": _3,
                },
              ],
              elastx: [
                0,
                {
                  "jls-sto1": _3,
                  "jls-sto2": _3,
                  "jls-sto3": _3,
                },
              ],
              faststacks: _3,
              massivegrid: [
                0,
                {
                  paas: [
                    0,
                    {
                      "fr-1": _3,
                      "lon-1": _3,
                      "lon-2": _3,
                      "ny-1": _3,
                      "ny-2": _3,
                      "sg-1": _3,
                    },
                  ],
                },
              ],
              saveincloud: [
                0,
                {
                  jelastic: _3,
                  "nordeste-idc": _3,
                },
              ],
              scaleforce: _28,
              tsukaeru: _29,
              kinghost: _3,
              uni5: _3,
              krellian: _3,
              barsy: _3,
              memset: _3,
              azurewebsites: _3,
              "azure-mobile": _3,
              cloudapp: _3,
              azurestaticapps: [
                2,
                {
                  1: _3,
                  2: _3,
                  3: _3,
                  centralus: _3,
                  eastasia: _3,
                  eastus2: _3,
                  westeurope: _3,
                  westus2: _3,
                },
              ],
              dnsup: _3,
              hicam: _3,
              "now-dns": _3,
              ownip: _3,
              vpndns: _3,
              "eating-organic": _3,
              mydissent: _3,
              myeffect: _3,
              mymediapc: _3,
              mypsx: _3,
              mysecuritycamera: _3,
              nhlfan: _3,
              "no-ip": _3,
              pgafan: _3,
              privatizehealthinsurance: _3,
              bounceme: _3,
              ddns: _3,
              redirectme: _3,
              serveblog: _3,
              serveminecraft: _3,
              sytes: _3,
              cloudycluster: _3,
              ovh: [
                0,
                {
                  webpaas: _5,
                  hosting: _5,
                },
              ],
              bar0: _3,
              bar1: _3,
              bar2: _3,
              rackmaze: _3,
              squares: _3,
              schokokeks: _3,
              "firewall-gateway": _3,
              seidat: _3,
              senseering: _3,
              siteleaf: _3,
              "vps-host": [
                2,
                {
                  jelastic: [
                    0,
                    {
                      atl: _3,
                      njs: _3,
                      ric: _3,
                    },
                  ],
                },
              ],
              myspreadshop: _3,
              srcf: [
                0,
                {
                  soc: _3,
                  user: _3,
                },
              ],
              supabase: _3,
              dsmynas: _3,
              familyds: _3,
              tailscale: [
                0,
                {
                  beta: _3,
                },
              ],
              ts: _3,
              torproject: [
                2,
                {
                  pages: _3,
                },
              ],
              "reserve-online": _3,
              "community-pro": _3,
              meinforum: _3,
              yandexcloud: [
                2,
                {
                  storage: _3,
                  website: _3,
                },
              ],
              za: _3,
            },
          ],
          nf: [
            1,
            {
              com: _2,
              net: _2,
              per: _2,
              rec: _2,
              web: _2,
              arts: _2,
              firm: _2,
              info: _2,
              other: _2,
              store: _2,
            },
          ],
          ng: [
            1,
            {
              com: _6,
              edu: _2,
              gov: _2,
              i: _2,
              mil: _2,
              mobi: _2,
              name: _2,
              net: _2,
              org: _2,
              sch: _2,
              col: _3,
              firm: _3,
              gen: _3,
              ltd: _3,
              ngo: _3,
            },
          ],
          ni: [
            1,
            {
              ac: _2,
              biz: _2,
              co: _2,
              com: _2,
              edu: _2,
              gob: _2,
              in: _2,
              info: _2,
              int: _2,
              mil: _2,
              net: _2,
              nom: _2,
              org: _2,
              web: _2,
            },
          ],
          nl: [
            1,
            {
              co: _3,
              "hosting-cluster": _3,
              blogspot: _3,
              gov: _3,
              khplay: _3,
              "123website": _3,
              myspreadshop: _3,
              transurl: _5,
              cistron: _3,
              demon: _3,
            },
          ],
          no: [
            1,
            {
              fhs: _2,
              vgs: _2,
              fylkesbibl: _2,
              folkebibl: _2,
              museum: _2,
              idrett: _2,
              priv: _2,
              mil: _2,
              stat: _2,
              dep: _2,
              kommune: _2,
              herad: _2,
              aa: _40,
              ah: _40,
              bu: _40,
              fm: _40,
              hl: _40,
              hm: _40,
              "jan-mayen": _40,
              mr: _40,
              nl: _40,
              nt: _40,
              of: _40,
              ol: _40,
              oslo: _40,
              rl: _40,
              sf: _40,
              st: _40,
              svalbard: _40,
              tm: _40,
              tr: _40,
              va: _40,
              vf: _40,
              akrehamn: _2,
              "xn--krehamn-dxa": _2,
              åkrehamn: _2,
              algard: _2,
              "xn--lgrd-poac": _2,
              ålgård: _2,
              arna: _2,
              brumunddal: _2,
              bryne: _2,
              bronnoysund: _2,
              "xn--brnnysund-m8ac": _2,
              brønnøysund: _2,
              drobak: _2,
              "xn--drbak-wua": _2,
              drøbak: _2,
              egersund: _2,
              fetsund: _2,
              floro: _2,
              "xn--flor-jra": _2,
              florø: _2,
              fredrikstad: _2,
              hokksund: _2,
              honefoss: _2,
              "xn--hnefoss-q1a": _2,
              hønefoss: _2,
              jessheim: _2,
              jorpeland: _2,
              "xn--jrpeland-54a": _2,
              jørpeland: _2,
              kirkenes: _2,
              kopervik: _2,
              krokstadelva: _2,
              langevag: _2,
              "xn--langevg-jxa": _2,
              langevåg: _2,
              leirvik: _2,
              mjondalen: _2,
              "xn--mjndalen-64a": _2,
              mjøndalen: _2,
              "mo-i-rana": _2,
              mosjoen: _2,
              "xn--mosjen-eya": _2,
              mosjøen: _2,
              nesoddtangen: _2,
              orkanger: _2,
              osoyro: _2,
              "xn--osyro-wua": _2,
              osøyro: _2,
              raholt: _2,
              "xn--rholt-mra": _2,
              råholt: _2,
              sandnessjoen: _2,
              "xn--sandnessjen-ogb": _2,
              sandnessjøen: _2,
              skedsmokorset: _2,
              slattum: _2,
              spjelkavik: _2,
              stathelle: _2,
              stavern: _2,
              stjordalshalsen: _2,
              "xn--stjrdalshalsen-sqb": _2,
              stjørdalshalsen: _2,
              tananger: _2,
              tranby: _2,
              vossevangen: _2,
              afjord: _2,
              "xn--fjord-lra": _2,
              åfjord: _2,
              agdenes: _2,
              al: _2,
              "xn--l-1fa": _2,
              ål: _2,
              alesund: _2,
              "xn--lesund-hua": _2,
              ålesund: _2,
              alstahaug: _2,
              alta: _2,
              "xn--lt-liac": _2,
              áltá: _2,
              alaheadju: _2,
              "xn--laheadju-7ya": _2,
              álaheadju: _2,
              alvdal: _2,
              amli: _2,
              "xn--mli-tla": _2,
              åmli: _2,
              amot: _2,
              "xn--mot-tla": _2,
              åmot: _2,
              andebu: _2,
              andoy: _2,
              "xn--andy-ira": _2,
              andøy: _2,
              andasuolo: _2,
              ardal: _2,
              "xn--rdal-poa": _2,
              årdal: _2,
              aremark: _2,
              arendal: _2,
              "xn--s-1fa": _2,
              ås: _2,
              aseral: _2,
              "xn--seral-lra": _2,
              åseral: _2,
              asker: _2,
              askim: _2,
              askvoll: _2,
              askoy: _2,
              "xn--asky-ira": _2,
              askøy: _2,
              asnes: _2,
              "xn--snes-poa": _2,
              åsnes: _2,
              audnedaln: _2,
              aukra: _2,
              aure: _2,
              aurland: _2,
              "aurskog-holand": _2,
              "xn--aurskog-hland-jnb": _2,
              "aurskog-høland": _2,
              austevoll: _2,
              austrheim: _2,
              averoy: _2,
              "xn--avery-yua": _2,
              averøy: _2,
              balestrand: _2,
              ballangen: _2,
              balat: _2,
              "xn--blt-elab": _2,
              bálát: _2,
              balsfjord: _2,
              bahccavuotna: _2,
              "xn--bhccavuotna-k7a": _2,
              báhccavuotna: _2,
              bamble: _2,
              bardu: _2,
              beardu: _2,
              beiarn: _2,
              bajddar: _2,
              "xn--bjddar-pta": _2,
              bájddar: _2,
              baidar: _2,
              "xn--bidr-5nac": _2,
              báidár: _2,
              berg: _2,
              bergen: _2,
              berlevag: _2,
              "xn--berlevg-jxa": _2,
              berlevåg: _2,
              bearalvahki: _2,
              "xn--bearalvhki-y4a": _2,
              bearalváhki: _2,
              bindal: _2,
              birkenes: _2,
              bjarkoy: _2,
              "xn--bjarky-fya": _2,
              bjarkøy: _2,
              bjerkreim: _2,
              bjugn: _2,
              bodo: _2,
              "xn--bod-2na": _2,
              bodø: _2,
              badaddja: _2,
              "xn--bdddj-mrabd": _2,
              bådåddjå: _2,
              budejju: _2,
              bokn: _2,
              bremanger: _2,
              bronnoy: _2,
              "xn--brnny-wuac": _2,
              brønnøy: _2,
              bygland: _2,
              bykle: _2,
              barum: _2,
              "xn--brum-voa": _2,
              bærum: _2,
              telemark: [
                0,
                {
                  bo: _2,
                  "xn--b-5ga": _2,
                  bø: _2,
                },
              ],
              nordland: [
                0,
                {
                  bo: _2,
                  "xn--b-5ga": _2,
                  bø: _2,
                  heroy: _2,
                  "xn--hery-ira": _2,
                  herøy: _2,
                },
              ],
              bievat: _2,
              "xn--bievt-0qa": _2,
              bievát: _2,
              bomlo: _2,
              "xn--bmlo-gra": _2,
              bømlo: _2,
              batsfjord: _2,
              "xn--btsfjord-9za": _2,
              båtsfjord: _2,
              bahcavuotna: _2,
              "xn--bhcavuotna-s4a": _2,
              báhcavuotna: _2,
              dovre: _2,
              drammen: _2,
              drangedal: _2,
              dyroy: _2,
              "xn--dyry-ira": _2,
              dyrøy: _2,
              donna: _2,
              "xn--dnna-gra": _2,
              dønna: _2,
              eid: _2,
              eidfjord: _2,
              eidsberg: _2,
              eidskog: _2,
              eidsvoll: _2,
              eigersund: _2,
              elverum: _2,
              enebakk: _2,
              engerdal: _2,
              etne: _2,
              etnedal: _2,
              evenes: _2,
              evenassi: _2,
              "xn--eveni-0qa01ga": _2,
              evenášši: _2,
              "evje-og-hornnes": _2,
              farsund: _2,
              fauske: _2,
              fuossko: _2,
              fuoisku: _2,
              fedje: _2,
              fet: _2,
              finnoy: _2,
              "xn--finny-yua": _2,
              finnøy: _2,
              fitjar: _2,
              fjaler: _2,
              fjell: _2,
              flakstad: _2,
              flatanger: _2,
              flekkefjord: _2,
              flesberg: _2,
              flora: _2,
              fla: _2,
              "xn--fl-zia": _2,
              flå: _2,
              folldal: _2,
              forsand: _2,
              fosnes: _2,
              frei: _2,
              frogn: _2,
              froland: _2,
              frosta: _2,
              frana: _2,
              "xn--frna-woa": _2,
              fræna: _2,
              froya: _2,
              "xn--frya-hra": _2,
              frøya: _2,
              fusa: _2,
              fyresdal: _2,
              forde: _2,
              "xn--frde-gra": _2,
              førde: _2,
              gamvik: _2,
              gangaviika: _2,
              "xn--ggaviika-8ya47h": _2,
              gáŋgaviika: _2,
              gaular: _2,
              gausdal: _2,
              gildeskal: _2,
              "xn--gildeskl-g0a": _2,
              gildeskål: _2,
              giske: _2,
              gjemnes: _2,
              gjerdrum: _2,
              gjerstad: _2,
              gjesdal: _2,
              gjovik: _2,
              "xn--gjvik-wua": _2,
              gjøvik: _2,
              gloppen: _2,
              gol: _2,
              gran: _2,
              grane: _2,
              granvin: _2,
              gratangen: _2,
              grimstad: _2,
              grong: _2,
              kraanghke: _2,
              "xn--kranghke-b0a": _2,
              kråanghke: _2,
              grue: _2,
              gulen: _2,
              hadsel: _2,
              halden: _2,
              halsa: _2,
              hamar: _2,
              hamaroy: _2,
              habmer: _2,
              "xn--hbmer-xqa": _2,
              hábmer: _2,
              hapmir: _2,
              "xn--hpmir-xqa": _2,
              hápmir: _2,
              hammerfest: _2,
              hammarfeasta: _2,
              "xn--hmmrfeasta-s4ac": _2,
              hámmárfeasta: _2,
              haram: _2,
              hareid: _2,
              harstad: _2,
              hasvik: _2,
              aknoluokta: _2,
              "xn--koluokta-7ya57h": _2,
              ákŋoluokta: _2,
              hattfjelldal: _2,
              aarborte: _2,
              haugesund: _2,
              hemne: _2,
              hemnes: _2,
              hemsedal: _2,
              "more-og-romsdal": [
                0,
                {
                  heroy: _2,
                  sande: _2,
                },
              ],
              "xn--mre-og-romsdal-qqb": [
                0,
                {
                  "xn--hery-ira": _2,
                  sande: _2,
                },
              ],
              "møre-og-romsdal": [
                0,
                {
                  herøy: _2,
                  sande: _2,
                },
              ],
              hitra: _2,
              hjartdal: _2,
              hjelmeland: _2,
              hobol: _2,
              "xn--hobl-ira": _2,
              hobøl: _2,
              hof: _2,
              hol: _2,
              hole: _2,
              holmestrand: _2,
              holtalen: _2,
              "xn--holtlen-hxa": _2,
              holtålen: _2,
              hornindal: _2,
              horten: _2,
              hurdal: _2,
              hurum: _2,
              hvaler: _2,
              hyllestad: _2,
              hagebostad: _2,
              "xn--hgebostad-g3a": _2,
              hægebostad: _2,
              hoyanger: _2,
              "xn--hyanger-q1a": _2,
              høyanger: _2,
              hoylandet: _2,
              "xn--hylandet-54a": _2,
              høylandet: _2,
              ha: _2,
              "xn--h-2fa": _2,
              hå: _2,
              ibestad: _2,
              inderoy: _2,
              "xn--indery-fya": _2,
              inderøy: _2,
              iveland: _2,
              jevnaker: _2,
              jondal: _2,
              jolster: _2,
              "xn--jlster-bya": _2,
              jølster: _2,
              karasjok: _2,
              karasjohka: _2,
              "xn--krjohka-hwab49j": _2,
              kárášjohka: _2,
              karlsoy: _2,
              galsa: _2,
              "xn--gls-elac": _2,
              gálsá: _2,
              karmoy: _2,
              "xn--karmy-yua": _2,
              karmøy: _2,
              kautokeino: _2,
              guovdageaidnu: _2,
              klepp: _2,
              klabu: _2,
              "xn--klbu-woa": _2,
              klæbu: _2,
              kongsberg: _2,
              kongsvinger: _2,
              kragero: _2,
              "xn--krager-gya": _2,
              kragerø: _2,
              kristiansand: _2,
              kristiansund: _2,
              krodsherad: _2,
              "xn--krdsherad-m8a": _2,
              krødsherad: _2,
              kvalsund: _2,
              rahkkeravju: _2,
              "xn--rhkkervju-01af": _2,
              ráhkkerávju: _2,
              kvam: _2,
              kvinesdal: _2,
              kvinnherad: _2,
              kviteseid: _2,
              kvitsoy: _2,
              "xn--kvitsy-fya": _2,
              kvitsøy: _2,
              kvafjord: _2,
              "xn--kvfjord-nxa": _2,
              kvæfjord: _2,
              giehtavuoatna: _2,
              kvanangen: _2,
              "xn--kvnangen-k0a": _2,
              kvænangen: _2,
              navuotna: _2,
              "xn--nvuotna-hwa": _2,
              návuotna: _2,
              kafjord: _2,
              "xn--kfjord-iua": _2,
              kåfjord: _2,
              gaivuotna: _2,
              "xn--givuotna-8ya": _2,
              gáivuotna: _2,
              larvik: _2,
              lavangen: _2,
              lavagis: _2,
              loabat: _2,
              "xn--loabt-0qa": _2,
              loabát: _2,
              lebesby: _2,
              davvesiida: _2,
              leikanger: _2,
              leirfjord: _2,
              leka: _2,
              leksvik: _2,
              lenvik: _2,
              leangaviika: _2,
              "xn--leagaviika-52b": _2,
              leaŋgaviika: _2,
              lesja: _2,
              levanger: _2,
              lier: _2,
              lierne: _2,
              lillehammer: _2,
              lillesand: _2,
              lindesnes: _2,
              lindas: _2,
              "xn--linds-pra": _2,
              lindås: _2,
              lom: _2,
              loppa: _2,
              lahppi: _2,
              "xn--lhppi-xqa": _2,
              láhppi: _2,
              lund: _2,
              lunner: _2,
              luroy: _2,
              "xn--lury-ira": _2,
              lurøy: _2,
              luster: _2,
              lyngdal: _2,
              lyngen: _2,
              ivgu: _2,
              lardal: _2,
              lerdal: _2,
              "xn--lrdal-sra": _2,
              lærdal: _2,
              lodingen: _2,
              "xn--ldingen-q1a": _2,
              lødingen: _2,
              lorenskog: _2,
              "xn--lrenskog-54a": _2,
              lørenskog: _2,
              loten: _2,
              "xn--lten-gra": _2,
              løten: _2,
              malvik: _2,
              masoy: _2,
              "xn--msy-ula0h": _2,
              måsøy: _2,
              muosat: _2,
              "xn--muost-0qa": _2,
              muosát: _2,
              mandal: _2,
              marker: _2,
              marnardal: _2,
              masfjorden: _2,
              meland: _2,
              meldal: _2,
              melhus: _2,
              meloy: _2,
              "xn--mely-ira": _2,
              meløy: _2,
              meraker: _2,
              "xn--merker-kua": _2,
              meråker: _2,
              moareke: _2,
              "xn--moreke-jua": _2,
              moåreke: _2,
              midsund: _2,
              "midtre-gauldal": _2,
              modalen: _2,
              modum: _2,
              molde: _2,
              moskenes: _2,
              moss: _2,
              mosvik: _2,
              malselv: _2,
              "xn--mlselv-iua": _2,
              målselv: _2,
              malatvuopmi: _2,
              "xn--mlatvuopmi-s4a": _2,
              málatvuopmi: _2,
              namdalseid: _2,
              aejrie: _2,
              namsos: _2,
              namsskogan: _2,
              naamesjevuemie: _2,
              "xn--nmesjevuemie-tcba": _2,
              nååmesjevuemie: _2,
              laakesvuemie: _2,
              nannestad: _2,
              narvik: _2,
              narviika: _2,
              naustdal: _2,
              "nedre-eiker": _2,
              akershus: _41,
              buskerud: _41,
              nesna: _2,
              nesodden: _2,
              nesseby: _2,
              unjarga: _2,
              "xn--unjrga-rta": _2,
              unjárga: _2,
              nesset: _2,
              nissedal: _2,
              nittedal: _2,
              "nord-aurdal": _2,
              "nord-fron": _2,
              "nord-odal": _2,
              norddal: _2,
              nordkapp: _2,
              davvenjarga: _2,
              "xn--davvenjrga-y4a": _2,
              davvenjárga: _2,
              "nordre-land": _2,
              nordreisa: _2,
              raisa: _2,
              "xn--risa-5na": _2,
              ráisa: _2,
              "nore-og-uvdal": _2,
              notodden: _2,
              naroy: _2,
              "xn--nry-yla5g": _2,
              nærøy: _2,
              notteroy: _2,
              "xn--nttery-byae": _2,
              nøtterøy: _2,
              odda: _2,
              oksnes: _2,
              "xn--ksnes-uua": _2,
              øksnes: _2,
              oppdal: _2,
              oppegard: _2,
              "xn--oppegrd-ixa": _2,
              oppegård: _2,
              orkdal: _2,
              orland: _2,
              "xn--rland-uua": _2,
              ørland: _2,
              orskog: _2,
              "xn--rskog-uua": _2,
              ørskog: _2,
              orsta: _2,
              "xn--rsta-fra": _2,
              ørsta: _2,
              hedmark: [
                0,
                {
                  os: _2,
                  valer: _2,
                  "xn--vler-qoa": _2,
                  våler: _2,
                },
              ],
              hordaland: [
                0,
                {
                  os: _2,
                },
              ],
              osen: _2,
              osteroy: _2,
              "xn--ostery-fya": _2,
              osterøy: _2,
              "ostre-toten": _2,
              "xn--stre-toten-zcb": _2,
              "østre-toten": _2,
              overhalla: _2,
              "ovre-eiker": _2,
              "xn--vre-eiker-k8a": _2,
              "øvre-eiker": _2,
              oyer: _2,
              "xn--yer-zna": _2,
              øyer: _2,
              oygarden: _2,
              "xn--ygarden-p1a": _2,
              øygarden: _2,
              "oystre-slidre": _2,
              "xn--ystre-slidre-ujb": _2,
              "øystre-slidre": _2,
              porsanger: _2,
              porsangu: _2,
              "xn--porsgu-sta26f": _2,
              porsáŋgu: _2,
              porsgrunn: _2,
              radoy: _2,
              "xn--rady-ira": _2,
              radøy: _2,
              rakkestad: _2,
              rana: _2,
              ruovat: _2,
              randaberg: _2,
              rauma: _2,
              rendalen: _2,
              rennebu: _2,
              rennesoy: _2,
              "xn--rennesy-v1a": _2,
              rennesøy: _2,
              rindal: _2,
              ringebu: _2,
              ringerike: _2,
              ringsaker: _2,
              rissa: _2,
              risor: _2,
              "xn--risr-ira": _2,
              risør: _2,
              roan: _2,
              rollag: _2,
              rygge: _2,
              ralingen: _2,
              "xn--rlingen-mxa": _2,
              rælingen: _2,
              rodoy: _2,
              "xn--rdy-0nab": _2,
              rødøy: _2,
              romskog: _2,
              "xn--rmskog-bya": _2,
              rømskog: _2,
              roros: _2,
              "xn--rros-gra": _2,
              røros: _2,
              rost: _2,
              "xn--rst-0na": _2,
              røst: _2,
              royken: _2,
              "xn--ryken-vua": _2,
              røyken: _2,
              royrvik: _2,
              "xn--ryrvik-bya": _2,
              røyrvik: _2,
              rade: _2,
              "xn--rde-ula": _2,
              råde: _2,
              salangen: _2,
              siellak: _2,
              saltdal: _2,
              salat: _2,
              "xn--slt-elab": _2,
              sálát: _2,
              "xn--slat-5na": _2,
              sálat: _2,
              samnanger: _2,
              vestfold: [
                0,
                {
                  sande: _2,
                },
              ],
              sandefjord: _2,
              sandnes: _2,
              sandoy: _2,
              "xn--sandy-yua": _2,
              sandøy: _2,
              sarpsborg: _2,
              sauda: _2,
              sauherad: _2,
              sel: _2,
              selbu: _2,
              selje: _2,
              seljord: _2,
              sigdal: _2,
              siljan: _2,
              sirdal: _2,
              skaun: _2,
              skedsmo: _2,
              ski: _2,
              skien: _2,
              skiptvet: _2,
              skjervoy: _2,
              "xn--skjervy-v1a": _2,
              skjervøy: _2,
              skierva: _2,
              "xn--skierv-uta": _2,
              skiervá: _2,
              skjak: _2,
              "xn--skjk-soa": _2,
              skjåk: _2,
              skodje: _2,
              skanland: _2,
              "xn--sknland-fxa": _2,
              skånland: _2,
              skanit: _2,
              "xn--sknit-yqa": _2,
              skánit: _2,
              smola: _2,
              "xn--smla-hra": _2,
              smøla: _2,
              snillfjord: _2,
              snasa: _2,
              "xn--snsa-roa": _2,
              snåsa: _2,
              snoasa: _2,
              snaase: _2,
              "xn--snase-nra": _2,
              snåase: _2,
              sogndal: _2,
              sokndal: _2,
              sola: _2,
              solund: _2,
              songdalen: _2,
              sortland: _2,
              spydeberg: _2,
              stange: _2,
              stavanger: _2,
              steigen: _2,
              steinkjer: _2,
              stjordal: _2,
              "xn--stjrdal-s1a": _2,
              stjørdal: _2,
              stokke: _2,
              "stor-elvdal": _2,
              stord: _2,
              stordal: _2,
              storfjord: _2,
              omasvuotna: _2,
              strand: _2,
              stranda: _2,
              stryn: _2,
              sula: _2,
              suldal: _2,
              sund: _2,
              sunndal: _2,
              surnadal: _2,
              sveio: _2,
              svelvik: _2,
              sykkylven: _2,
              sogne: _2,
              "xn--sgne-gra": _2,
              søgne: _2,
              somna: _2,
              "xn--smna-gra": _2,
              sømna: _2,
              "sondre-land": _2,
              "xn--sndre-land-0cb": _2,
              "søndre-land": _2,
              "sor-aurdal": _2,
              "xn--sr-aurdal-l8a": _2,
              "sør-aurdal": _2,
              "sor-fron": _2,
              "xn--sr-fron-q1a": _2,
              "sør-fron": _2,
              "sor-odal": _2,
              "xn--sr-odal-q1a": _2,
              "sør-odal": _2,
              "sor-varanger": _2,
              "xn--sr-varanger-ggb": _2,
              "sør-varanger": _2,
              "matta-varjjat": _2,
              "xn--mtta-vrjjat-k7af": _2,
              "mátta-várjjat": _2,
              sorfold: _2,
              "xn--srfold-bya": _2,
              sørfold: _2,
              sorreisa: _2,
              "xn--srreisa-q1a": _2,
              sørreisa: _2,
              sorum: _2,
              "xn--srum-gra": _2,
              sørum: _2,
              tana: _2,
              deatnu: _2,
              time: _2,
              tingvoll: _2,
              tinn: _2,
              tjeldsund: _2,
              dielddanuorri: _2,
              tjome: _2,
              "xn--tjme-hra": _2,
              tjøme: _2,
              tokke: _2,
              tolga: _2,
              torsken: _2,
              tranoy: _2,
              "xn--trany-yua": _2,
              tranøy: _2,
              tromso: _2,
              "xn--troms-zua": _2,
              tromsø: _2,
              tromsa: _2,
              romsa: _2,
              trondheim: _2,
              troandin: _2,
              trysil: _2,
              trana: _2,
              "xn--trna-woa": _2,
              træna: _2,
              trogstad: _2,
              "xn--trgstad-r1a": _2,
              trøgstad: _2,
              tvedestrand: _2,
              tydal: _2,
              tynset: _2,
              tysfjord: _2,
              divtasvuodna: _2,
              divttasvuotna: _2,
              tysnes: _2,
              tysvar: _2,
              "xn--tysvr-vra": _2,
              tysvær: _2,
              tonsberg: _2,
              "xn--tnsberg-q1a": _2,
              tønsberg: _2,
              ullensaker: _2,
              ullensvang: _2,
              ulvik: _2,
              utsira: _2,
              vadso: _2,
              "xn--vads-jra": _2,
              vadsø: _2,
              cahcesuolo: _2,
              "xn--hcesuolo-7ya35b": _2,
              čáhcesuolo: _2,
              vaksdal: _2,
              valle: _2,
              vang: _2,
              vanylven: _2,
              vardo: _2,
              "xn--vard-jra": _2,
              vardø: _2,
              varggat: _2,
              "xn--vrggt-xqad": _2,
              várggát: _2,
              vefsn: _2,
              vaapste: _2,
              vega: _2,
              vegarshei: _2,
              "xn--vegrshei-c0a": _2,
              vegårshei: _2,
              vennesla: _2,
              verdal: _2,
              verran: _2,
              vestby: _2,
              vestnes: _2,
              "vestre-slidre": _2,
              "vestre-toten": _2,
              vestvagoy: _2,
              "xn--vestvgy-ixa6o": _2,
              vestvågøy: _2,
              vevelstad: _2,
              vik: _2,
              vikna: _2,
              vindafjord: _2,
              volda: _2,
              voss: _2,
              varoy: _2,
              "xn--vry-yla5g": _2,
              værøy: _2,
              vagan: _2,
              "xn--vgan-qoa": _2,
              vågan: _2,
              voagat: _2,
              vagsoy: _2,
              "xn--vgsy-qoa0j": _2,
              vågsøy: _2,
              vaga: _2,
              "xn--vg-yiab": _2,
              vågå: _2,
              ostfold: [
                0,
                {
                  valer: _2,
                },
              ],
              "xn--stfold-9xa": [
                0,
                {
                  "xn--vler-qoa": _2,
                },
              ],
              østfold: [
                0,
                {
                  våler: _2,
                },
              ],
              co: _3,
              blogspot: _3,
              "123hjemmeside": _3,
              myspreadshop: _3,
            },
          ],
          np: _8,
          nr: _35,
          nu: [
            1,
            {
              merseine: _3,
              mine: _3,
              shacknet: _3,
              enterprisecloud: _3,
            },
          ],
          nz: [
            1,
            {
              ac: _2,
              co: _6,
              cri: _2,
              geek: _2,
              gen: _2,
              govt: _2,
              health: _2,
              iwi: _2,
              kiwi: _2,
              maori: _2,
              mil: _2,
              "xn--mori-qsa": _2,
              māori: _2,
              net: _2,
              org: _2,
              parliament: _2,
              school: _2,
            },
          ],
          om: [
            1,
            {
              co: _2,
              com: _2,
              edu: _2,
              gov: _2,
              med: _2,
              museum: _2,
              net: _2,
              org: _2,
              pro: _2,
            },
          ],
          onion: _2,
          org: [
            1,
            {
              altervista: _3,
              amune: [
                0,
                {
                  tele: _3,
                },
              ],
              pimienta: _3,
              poivron: _3,
              potager: _3,
              sweetpepper: _3,
              ae: _3,
              us: _3,
              certmgr: _3,
              cdn77: [
                0,
                {
                  c: _3,
                  rsc: _3,
                },
              ],
              "cdn77-secure": [
                0,
                {
                  origin: [
                    0,
                    {
                      ssl: _3,
                    },
                  ],
                },
              ],
              cloudns: _3,
              duckdns: _3,
              tunk: _3,
              dyndns: [
                2,
                {
                  go: _3,
                  home: _3,
                },
              ],
              blogdns: _3,
              blogsite: _3,
              boldlygoingnowhere: _3,
              dnsalias: _3,
              dnsdojo: _3,
              doesntexist: _3,
              dontexist: _3,
              doomdns: _3,
              dvrdns: _3,
              dynalias: _3,
              endofinternet: _3,
              endoftheinternet: _3,
              "from-me": _3,
              "game-host": _3,
              gotdns: _3,
              "hobby-site": _3,
              homedns: _3,
              homeftp: _3,
              homelinux: _3,
              homeunix: _3,
              "is-a-bruinsfan": _3,
              "is-a-candidate": _3,
              "is-a-celticsfan": _3,
              "is-a-chef": _3,
              "is-a-geek": _3,
              "is-a-knight": _3,
              "is-a-linux-user": _3,
              "is-a-patsfan": _3,
              "is-a-soxfan": _3,
              "is-found": _3,
              "is-lost": _3,
              "is-saved": _3,
              "is-very-bad": _3,
              "is-very-evil": _3,
              "is-very-good": _3,
              "is-very-nice": _3,
              "is-very-sweet": _3,
              "isa-geek": _3,
              "kicks-ass": _3,
              misconfused: _3,
              podzone: _3,
              readmyblog: _3,
              selfip: _3,
              sellsyourhome: _3,
              servebbs: _3,
              serveftp: _3,
              servegame: _3,
              "stuff-4-sale": _3,
              webhop: _3,
              ddnss: _3,
              accesscam: _3,
              camdvr: _3,
              freeddns: _3,
              mywire: _3,
              webredirect: _3,
              eu: [
                2,
                {
                  al: _3,
                  asso: _3,
                  at: _3,
                  au: _3,
                  be: _3,
                  bg: _3,
                  ca: _3,
                  cd: _3,
                  ch: _3,
                  cn: _3,
                  cy: _3,
                  cz: _3,
                  de: _3,
                  dk: _3,
                  edu: _3,
                  ee: _3,
                  es: _3,
                  fi: _3,
                  fr: _3,
                  gr: _3,
                  hr: _3,
                  hu: _3,
                  ie: _3,
                  il: _3,
                  in: _3,
                  int: _3,
                  is: _3,
                  it: _3,
                  jp: _3,
                  kr: _3,
                  lt: _3,
                  lu: _3,
                  lv: _3,
                  mc: _3,
                  me: _3,
                  mk: _3,
                  mt: _3,
                  my: _3,
                  net: _3,
                  ng: _3,
                  nl: _3,
                  no: _3,
                  nz: _3,
                  paris: _3,
                  pl: _3,
                  pt: _3,
                  "q-a": _3,
                  ro: _3,
                  ru: _3,
                  se: _3,
                  si: _3,
                  sk: _3,
                  tr: _3,
                  uk: _3,
                  us: _3,
                },
              ],
              twmail: _3,
              fedorainfracloud: _3,
              fedorapeople: _3,
              fedoraproject: [
                0,
                {
                  cloud: _3,
                  os: _23,
                  stg: [
                    0,
                    {
                      os: _23,
                    },
                  ],
                },
              ],
              freedesktop: _3,
              hepforge: _3,
              "in-dsl": _3,
              "in-vpn": _3,
              js: _3,
              barsy: _3,
              mayfirst: _3,
              "mozilla-iot": _3,
              bmoattachments: _3,
              dynserv: _3,
              "now-dns": _3,
              "cable-modem": _3,
              collegefan: _3,
              couchpotatofries: _3,
              mlbfan: _3,
              mysecuritycamera: _3,
              nflfan: _3,
              "read-books": _3,
              ufcfan: _3,
              hopto: _3,
              myftp: _3,
              "no-ip": _3,
              zapto: _3,
              httpbin: _3,
              pubtls: _3,
              jpn: _3,
              "my-firewall": _3,
              myfirewall: _3,
              spdns: _3,
              "small-web": _3,
              dsmynas: _3,
              familyds: _3,
              teckids: _12,
              tuxfamily: _3,
              diskstation: _3,
              hk: _3,
              wmflabs: _3,
              toolforge: _3,
              wmcloud: _3,
              za: _3,
            },
          ],
          pa: [
            1,
            {
              ac: _2,
              gob: _2,
              com: _2,
              org: _2,
              sld: _2,
              edu: _2,
              net: _2,
              ing: _2,
              abo: _2,
              med: _2,
              nom: _2,
            },
          ],
          pe: [
            1,
            {
              edu: _2,
              gob: _2,
              nom: _2,
              mil: _2,
              org: _2,
              com: _2,
              net: _2,
              blogspot: _3,
            },
          ],
          pf: [
            1,
            {
              com: _2,
              org: _2,
              edu: _2,
            },
          ],
          pg: _8,
          ph: [
            1,
            {
              com: _2,
              net: _2,
              org: _2,
              gov: _2,
              edu: _2,
              ngo: _2,
              mil: _2,
              i: _2,
            },
          ],
          pk: [
            1,
            {
              com: _2,
              net: _2,
              edu: _2,
              org: _2,
              fam: _2,
              biz: _2,
              web: _2,
              gov: _2,
              gob: _2,
              gok: _2,
              gon: _2,
              gop: _2,
              gos: _2,
              info: _2,
            },
          ],
          pl: [
            1,
            {
              com: _2,
              net: _2,
              org: _2,
              aid: _2,
              agro: _2,
              atm: _2,
              auto: _2,
              biz: _2,
              edu: _2,
              gmina: _2,
              gsm: _2,
              info: _2,
              mail: _2,
              miasta: _2,
              media: _2,
              mil: _2,
              nieruchomosci: _2,
              nom: _2,
              pc: _2,
              powiat: _2,
              priv: _2,
              realestate: _2,
              rel: _2,
              sex: _2,
              shop: _2,
              sklep: _2,
              sos: _2,
              szkola: _2,
              targi: _2,
              tm: _2,
              tourism: _2,
              travel: _2,
              turystyka: _2,
              gov: [
                1,
                {
                  ap: _2,
                  griw: _2,
                  ic: _2,
                  is: _2,
                  kmpsp: _2,
                  konsulat: _2,
                  kppsp: _2,
                  kwp: _2,
                  kwpsp: _2,
                  mup: _2,
                  mw: _2,
                  oia: _2,
                  oirm: _2,
                  oke: _2,
                  oow: _2,
                  oschr: _2,
                  oum: _2,
                  pa: _2,
                  pinb: _2,
                  piw: _2,
                  po: _2,
                  pr: _2,
                  psp: _2,
                  psse: _2,
                  pup: _2,
                  rzgw: _2,
                  sa: _2,
                  sdn: _2,
                  sko: _2,
                  so: _2,
                  sr: _2,
                  starostwo: _2,
                  ug: _2,
                  ugim: _2,
                  um: _2,
                  umig: _2,
                  upow: _2,
                  uppo: _2,
                  us: _2,
                  uw: _2,
                  uzs: _2,
                  wif: _2,
                  wiih: _2,
                  winb: _2,
                  wios: _2,
                  witd: _2,
                  wiw: _2,
                  wkz: _2,
                  wsa: _2,
                  wskr: _2,
                  wsse: _2,
                  wuoz: _2,
                  wzmiuw: _2,
                  zp: _2,
                  zpisdn: _2,
                },
              ],
              augustow: _2,
              "babia-gora": _2,
              bedzin: _2,
              beskidy: _2,
              bialowieza: _2,
              bialystok: _2,
              bielawa: _2,
              bieszczady: _2,
              boleslawiec: _2,
              bydgoszcz: _2,
              bytom: _2,
              cieszyn: _2,
              czeladz: _2,
              czest: _2,
              dlugoleka: _2,
              elblag: _2,
              elk: _2,
              glogow: _2,
              gniezno: _2,
              gorlice: _2,
              grajewo: _2,
              ilawa: _2,
              jaworzno: _2,
              "jelenia-gora": _2,
              jgora: _2,
              kalisz: _2,
              "kazimierz-dolny": _2,
              karpacz: _2,
              kartuzy: _2,
              kaszuby: _2,
              katowice: _2,
              kepno: _2,
              ketrzyn: _2,
              klodzko: _2,
              kobierzyce: _2,
              kolobrzeg: _2,
              konin: _2,
              konskowola: _2,
              kutno: _2,
              lapy: _2,
              lebork: _2,
              legnica: _2,
              lezajsk: _2,
              limanowa: _2,
              lomza: _2,
              lowicz: _2,
              lubin: _2,
              lukow: _2,
              malbork: _2,
              malopolska: _2,
              mazowsze: _2,
              mazury: _2,
              mielec: _2,
              mielno: _2,
              mragowo: _2,
              naklo: _2,
              nowaruda: _2,
              nysa: _2,
              olawa: _2,
              olecko: _2,
              olkusz: _2,
              olsztyn: _2,
              opoczno: _2,
              opole: _2,
              ostroda: _2,
              ostroleka: _2,
              ostrowiec: _2,
              ostrowwlkp: _2,
              pila: _2,
              pisz: _2,
              podhale: _2,
              podlasie: _2,
              polkowice: _2,
              pomorze: _2,
              pomorskie: _2,
              prochowice: _2,
              pruszkow: _2,
              przeworsk: _2,
              pulawy: _2,
              radom: _2,
              "rawa-maz": _2,
              rybnik: _2,
              rzeszow: _2,
              sanok: _2,
              sejny: _2,
              slask: _2,
              slupsk: _2,
              sosnowiec: _2,
              "stalowa-wola": _2,
              skoczow: _2,
              starachowice: _2,
              stargard: _2,
              suwalki: _2,
              swidnica: _2,
              swiebodzin: _2,
              swinoujscie: _2,
              szczecin: _2,
              szczytno: _2,
              tarnobrzeg: _2,
              tgory: _2,
              turek: _2,
              tychy: _2,
              ustka: _2,
              walbrzych: _2,
              warmia: _2,
              warszawa: _2,
              waw: _2,
              wegrow: _2,
              wielun: _2,
              wlocl: _2,
              wloclawek: _2,
              wodzislaw: _2,
              wolomin: _2,
              wroclaw: _2,
              zachpomor: _2,
              zagan: _2,
              zarow: _2,
              zgora: _2,
              zgorzelec: _2,
              beep: _3,
              "ecommerce-shop": _3,
              shoparena: _3,
              homesklep: _3,
              sdscloud: _3,
              unicloud: _3,
              krasnik: _3,
              leczna: _3,
              lubartow: _3,
              lublin: _3,
              poniatowa: _3,
              swidnik: _3,
              co: _3,
              simplesite: _3,
              art: _3,
              gliwice: _3,
              krakow: _3,
              poznan: _3,
              wroc: _3,
              zakopane: _3,
              myspreadshop: _3,
              gda: _3,
              gdansk: _3,
              gdynia: _3,
              med: _3,
              sopot: _3,
            },
          ],
          pm: [
            1,
            {
              own: _3,
              name: _3,
            },
          ],
          pn: [
            1,
            {
              gov: _2,
              co: _2,
              org: _2,
              edu: _2,
              net: _2,
            },
          ],
          post: _2,
          pr: [
            1,
            {
              com: _2,
              net: _2,
              org: _2,
              gov: _2,
              edu: _2,
              isla: _2,
              pro: _2,
              biz: _2,
              info: _2,
              name: _2,
              est: _2,
              prof: _2,
              ac: _2,
            },
          ],
          pro: [
            1,
            {
              aaa: _2,
              aca: _2,
              acct: _2,
              avocat: _2,
              bar: _2,
              cpa: _2,
              eng: _2,
              jur: _2,
              law: _2,
              med: _2,
              recht: _2,
              cloudns: _3,
              dnstrace: [
                0,
                {
                  bci: _3,
                },
              ],
              barsy: _3,
            },
          ],
          ps: [
            1,
            {
              edu: _2,
              gov: _2,
              sec: _2,
              plo: _2,
              com: _2,
              org: _2,
              net: _2,
            },
          ],
          pt: [
            1,
            {
              net: _2,
              gov: _2,
              org: _2,
              edu: _2,
              int: _2,
              publ: _2,
              com: _2,
              nome: _2,
              blogspot: _3,
              "123paginaweb": _3,
            },
          ],
          pw: [
            1,
            {
              co: _2,
              ne: _2,
              or: _2,
              ed: _2,
              go: _2,
              belau: _2,
              cloudns: _3,
              x443: _3,
            },
          ],
          py: [
            1,
            {
              com: _2,
              coop: _2,
              edu: _2,
              gov: _2,
              mil: _2,
              net: _2,
              org: _2,
            },
          ],
          qa: [
            1,
            {
              com: _2,
              edu: _2,
              gov: _2,
              mil: _2,
              name: _2,
              net: _2,
              org: _2,
              sch: _2,
              blogspot: _3,
            },
          ],
          re: [
            1,
            {
              asso: _2,
              com: _2,
              nom: _2,
              blogspot: _3,
            },
          ],
          ro: [
            1,
            {
              arts: _2,
              com: _2,
              firm: _2,
              info: _2,
              nom: _2,
              nt: _2,
              org: _2,
              rec: _2,
              store: _2,
              tm: _2,
              www: _2,
              co: _3,
              shop: _3,
              blogspot: _3,
              barsy: _3,
            },
          ],
          rs: [
            1,
            {
              ac: _2,
              co: _2,
              edu: _2,
              gov: _2,
              in: _2,
              org: _2,
              brendly: [
                0,
                {
                  shop: _3,
                },
              ],
              blogspot: _3,
              ua: _3,
              ox: _3,
            },
          ],
          ru: [
            1,
            {
              ac: _3,
              edu: _3,
              gov: _3,
              int: _3,
              mil: _3,
              test: _3,
              eurodir: _3,
              adygeya: _3,
              bashkiria: _3,
              bir: _3,
              cbg: _3,
              com: _3,
              dagestan: _3,
              grozny: _3,
              kalmykia: _3,
              kustanai: _3,
              marine: _3,
              mordovia: _3,
              msk: _3,
              mytis: _3,
              nalchik: _3,
              nov: _3,
              pyatigorsk: _3,
              spb: _3,
              vladikavkaz: _3,
              vladimir: _3,
              blogspot: _3,
              na4u: _3,
              mircloud: _3,
              regruhosting: _29,
              myjino: [
                2,
                {
                  hosting: _5,
                  landing: _5,
                  spectrum: _5,
                  vps: _5,
                },
              ],
              cldmail: [
                0,
                {
                  hb: _3,
                },
              ],
              mcdir: [
                2,
                {
                  vps: _3,
                },
              ],
              mcpre: _3,
              net: _3,
              org: _3,
              pp: _3,
              "123sait": _3,
              lk3: _3,
              ras: _3,
            },
          ],
          rw: [
            1,
            {
              ac: _2,
              co: _2,
              coop: _2,
              gov: _2,
              mil: _2,
              net: _2,
              org: _2,
            },
          ],
          sa: [
            1,
            {
              com: _2,
              net: _2,
              org: _2,
              gov: _2,
              med: _2,
              pub: _2,
              edu: _2,
              sch: _2,
            },
          ],
          sb: _4,
          sc: _4,
          sd: [
            1,
            {
              com: _2,
              net: _2,
              org: _2,
              edu: _2,
              med: _2,
              tv: _2,
              gov: _2,
              info: _2,
            },
          ],
          se: [
            1,
            {
              a: _2,
              ac: _2,
              b: _2,
              bd: _2,
              brand: _2,
              c: _2,
              d: _2,
              e: _2,
              f: _2,
              fh: _2,
              fhsk: _2,
              fhv: _2,
              g: _2,
              h: _2,
              i: _2,
              k: _2,
              komforb: _2,
              kommunalforbund: _2,
              komvux: _2,
              l: _2,
              lanbib: _2,
              m: _2,
              n: _2,
              naturbruksgymn: _2,
              o: _2,
              org: _2,
              p: _2,
              parti: _2,
              pp: _2,
              press: _2,
              r: _2,
              s: _2,
              t: _2,
              tm: _2,
              u: _2,
              w: _2,
              x: _2,
              y: _2,
              z: _2,
              com: _3,
              blogspot: _3,
              conf: _3,
              iopsys: _3,
              "123minsida": _3,
              itcouldbewor: _3,
              myspreadshop: _3,
              paba: [
                0,
                {
                  su: _3,
                },
              ],
            },
          ],
          sg: [
            1,
            {
              com: _2,
              net: _2,
              org: _2,
              gov: _2,
              edu: _2,
              per: _2,
              blogspot: _3,
              enscaled: _3,
            },
          ],
          sh: [
            1,
            {
              com: _2,
              net: _2,
              gov: _2,
              org: _2,
              mil: _2,
              bip: _3,
              hashbang: _3,
              platform: [
                0,
                {
                  bc: _3,
                  ent: _3,
                  eu: _3,
                  us: _3,
                },
              ],
              now: _3,
              vxl: _3,
              wedeploy: _3,
            },
          ],
          si: [
            1,
            {
              gitapp: _3,
              gitpage: _3,
              blogspot: _3,
            },
          ],
          sj: _2,
          sk: _6,
          sl: _4,
          sm: _2,
          sn: [
            1,
            {
              art: _2,
              com: _2,
              edu: _2,
              gouv: _2,
              org: _2,
              perso: _2,
              univ: _2,
              blogspot: _3,
            },
          ],
          so: [
            1,
            {
              com: _2,
              edu: _2,
              gov: _2,
              me: _2,
              net: _2,
              org: _2,
              sch: _3,
            },
          ],
          sr: _2,
          ss: [
            1,
            {
              biz: _2,
              com: _2,
              edu: _2,
              gov: _2,
              me: _2,
              net: _2,
              org: _2,
              sch: _2,
            },
          ],
          st: [
            1,
            {
              co: _2,
              com: _2,
              consulado: _2,
              edu: _2,
              embaixada: _2,
              mil: _2,
              net: _2,
              org: _2,
              principe: _2,
              saotome: _2,
              store: _2,
              kirara: _3,
              noho: _3,
            },
          ],
          su: [
            1,
            {
              abkhazia: _3,
              adygeya: _3,
              aktyubinsk: _3,
              arkhangelsk: _3,
              armenia: _3,
              ashgabad: _3,
              azerbaijan: _3,
              balashov: _3,
              bashkiria: _3,
              bryansk: _3,
              bukhara: _3,
              chimkent: _3,
              dagestan: _3,
              "east-kazakhstan": _3,
              exnet: _3,
              georgia: _3,
              grozny: _3,
              ivanovo: _3,
              jambyl: _3,
              kalmykia: _3,
              kaluga: _3,
              karacol: _3,
              karaganda: _3,
              karelia: _3,
              khakassia: _3,
              krasnodar: _3,
              kurgan: _3,
              kustanai: _3,
              lenug: _3,
              mangyshlak: _3,
              mordovia: _3,
              msk: _3,
              murmansk: _3,
              nalchik: _3,
              navoi: _3,
              "north-kazakhstan": _3,
              nov: _3,
              obninsk: _3,
              penza: _3,
              pokrovsk: _3,
              sochi: _3,
              spb: _3,
              tashkent: _3,
              termez: _3,
              togliatti: _3,
              troitsk: _3,
              tselinograd: _3,
              tula: _3,
              tuva: _3,
              vladikavkaz: _3,
              vladimir: _3,
              vologda: _3,
            },
          ],
          sv: [
            1,
            {
              com: _2,
              edu: _2,
              gob: _2,
              org: _2,
              red: _2,
            },
          ],
          sx: _7,
          sy: _34,
          sz: [
            1,
            {
              co: _2,
              ac: _2,
              org: _2,
            },
          ],
          tc: [
            1,
            {
              ch: _3,
              me: _3,
              we: _3,
            },
          ],
          td: _6,
          tel: _2,
          tf: [
            1,
            {
              sch: _3,
            },
          ],
          tg: _2,
          th: [
            1,
            {
              ac: _2,
              co: _2,
              go: _2,
              in: _2,
              mi: _2,
              net: _2,
              or: _2,
              online: _3,
              shop: _3,
            },
          ],
          tj: [
            1,
            {
              ac: _2,
              biz: _2,
              co: _2,
              com: _2,
              edu: _2,
              go: _2,
              gov: _2,
              int: _2,
              mil: _2,
              name: _2,
              net: _2,
              nic: _2,
              org: _2,
              test: _2,
              web: _2,
            },
          ],
          tk: _2,
          tl: _7,
          tm: [
            1,
            {
              com: _2,
              co: _2,
              org: _2,
              net: _2,
              nom: _2,
              gov: _2,
              mil: _2,
              edu: _2,
            },
          ],
          tn: [
            1,
            {
              com: _2,
              ens: _2,
              fin: _2,
              gov: _2,
              ind: _2,
              info: _2,
              intl: _2,
              mincom: _2,
              nat: _2,
              net: _2,
              org: _2,
              perso: _2,
              tourism: _2,
              orangecloud: _3,
            },
          ],
          to: [
            1,
            {
              611: _3,
              com: _2,
              gov: _2,
              net: _2,
              org: _2,
              edu: _2,
              mil: _2,
              oya: _3,
              rdv: _3,
              x0: _3,
              vpnplus: _3,
              quickconnect: _13,
              nyan: _3,
            },
          ],
          tr: [
            1,
            {
              av: _2,
              bbs: _2,
              bel: _2,
              biz: _2,
              com: _6,
              dr: _2,
              edu: _2,
              gen: _2,
              gov: _2,
              info: _2,
              mil: _2,
              k12: _2,
              kep: _2,
              name: _2,
              net: _2,
              org: _2,
              pol: _2,
              tel: _2,
              tsk: _2,
              tv: _2,
              web: _2,
              nc: _7,
            },
          ],
          tt: [
            1,
            {
              co: _2,
              com: _2,
              org: _2,
              net: _2,
              biz: _2,
              info: _2,
              pro: _2,
              int: _2,
              coop: _2,
              jobs: _2,
              mobi: _2,
              travel: _2,
              museum: _2,
              aero: _2,
              name: _2,
              gov: _2,
              edu: _2,
            },
          ],
          tv: [
            1,
            {
              dyndns: _3,
              "better-than": _3,
              "on-the-web": _3,
              "worse-than": _3,
              from: _3,
              sakura: _3,
            },
          ],
          tw: [
            1,
            {
              edu: _2,
              gov: _2,
              mil: _2,
              com: [
                1,
                {
                  mymailer: _3,
                },
              ],
              net: _2,
              org: _2,
              idv: _2,
              game: _2,
              ebiz: _2,
              club: _2,
              "xn--zf0ao64a": _2,
              網路: _2,
              "xn--uc0atv": _2,
              組織: _2,
              "xn--czrw28b": _2,
              商業: _2,
              url: _3,
              blogspot: _3,
            },
          ],
          tz: [
            1,
            {
              ac: _2,
              co: _2,
              go: _2,
              hotel: _2,
              info: _2,
              me: _2,
              mil: _2,
              mobi: _2,
              ne: _2,
              or: _2,
              sc: _2,
              tv: _2,
            },
          ],
          ua: [
            1,
            {
              com: _2,
              edu: _2,
              gov: _2,
              in: _2,
              net: _2,
              org: _2,
              cherkassy: _2,
              cherkasy: _2,
              chernigov: _2,
              chernihiv: _2,
              chernivtsi: _2,
              chernovtsy: _2,
              ck: _2,
              cn: _2,
              cr: _2,
              crimea: _2,
              cv: _2,
              dn: _2,
              dnepropetrovsk: _2,
              dnipropetrovsk: _2,
              donetsk: _2,
              dp: _2,
              if: _2,
              "ivano-frankivsk": _2,
              kh: _2,
              kharkiv: _2,
              kharkov: _2,
              kherson: _2,
              khmelnitskiy: _2,
              khmelnytskyi: _2,
              kiev: _2,
              kirovograd: _2,
              km: _2,
              kr: _2,
              kropyvnytskyi: _2,
              krym: _2,
              ks: _2,
              kv: _2,
              kyiv: _2,
              lg: _2,
              lt: _2,
              lugansk: _2,
              lutsk: _2,
              lv: _2,
              lviv: _2,
              mk: _2,
              mykolaiv: _2,
              nikolaev: _2,
              od: _2,
              odesa: _2,
              odessa: _2,
              pl: _2,
              poltava: _2,
              rivne: _2,
              rovno: _2,
              rv: _2,
              sb: _2,
              sebastopol: _2,
              sevastopol: _2,
              sm: _2,
              sumy: _2,
              te: _2,
              ternopil: _2,
              uz: _2,
              uzhgorod: _2,
              vinnica: _2,
              vinnytsia: _2,
              vn: _2,
              volyn: _2,
              yalta: _2,
              zaporizhzhe: _2,
              zaporizhzhia: _2,
              zhitomir: _2,
              zhytomyr: _2,
              zp: _2,
              zt: _2,
              cc: _3,
              inf: _3,
              ltd: _3,
              cx: _3,
              ie: _3,
              biz: _3,
              co: _3,
              pp: _3,
              v: _3,
            },
          ],
          ug: [
            1,
            {
              co: _2,
              or: _2,
              ac: _2,
              sc: _2,
              go: _2,
              ne: _2,
              com: _2,
              org: _2,
              blogspot: _3,
            },
          ],
          uk: [
            1,
            {
              ac: _2,
              co: [
                1,
                {
                  bytemark: [
                    0,
                    {
                      dh: _3,
                      vm: _3,
                    },
                  ],
                  blogspot: _3,
                  layershift: _28,
                  barsy: _3,
                  barsyonline: _3,
                  retrosnub: _33,
                  "nh-serv": _3,
                  "no-ip": _3,
                  wellbeingzone: _3,
                  adimo: _3,
                  myspreadshop: _3,
                },
              ],
              gov: [
                1,
                {
                  campaign: _3,
                  service: _3,
                  api: _3,
                  homeoffice: _3,
                },
              ],
              ltd: _2,
              me: _2,
              net: _2,
              nhs: _2,
              org: [
                1,
                {
                  glug: _3,
                  lug: _3,
                  lugs: _3,
                  affinitylottery: _3,
                  raffleentry: _3,
                  weeklylottery: _3,
                },
              ],
              plc: _2,
              police: _2,
              sch: _8,
              conn: _3,
              copro: _3,
              hosp: _3,
              "independent-commission": _3,
              "independent-inquest": _3,
              "independent-inquiry": _3,
              "independent-panel": _3,
              "independent-review": _3,
              "public-inquiry": _3,
              "royal-commission": _3,
              pymnt: _3,
              barsy: _3,
            },
          ],
          us: [
            1,
            {
              dni: _2,
              fed: _2,
              isa: _2,
              kids: _2,
              nsn: _2,
              ak: _42,
              al: _42,
              ar: _42,
              as: _42,
              az: _42,
              ca: _42,
              co: _42,
              ct: _42,
              dc: _42,
              de: [
                1,
                {
                  k12: _2,
                  cc: _2,
                  lib: _3,
                },
              ],
              fl: _42,
              ga: _42,
              gu: _42,
              hi: _43,
              ia: _42,
              id: _42,
              il: _42,
              in: _42,
              ks: _42,
              ky: _42,
              la: _42,
              ma: [
                1,
                {
                  k12: [
                    1,
                    {
                      pvt: _2,
                      chtr: _2,
                      paroch: _2,
                    },
                  ],
                  cc: _2,
                  lib: _2,
                },
              ],
              md: _42,
              me: _42,
              mi: [
                1,
                {
                  k12: _2,
                  cc: _2,
                  lib: _2,
                  "ann-arbor": _2,
                  cog: _2,
                  dst: _2,
                  eaton: _2,
                  gen: _2,
                  mus: _2,
                  tec: _2,
                  washtenaw: _2,
                },
              ],
              mn: _42,
              mo: _42,
              ms: _42,
              mt: _42,
              nc: _42,
              nd: _43,
              ne: _42,
              nh: _42,
              nj: _42,
              nm: _42,
              nv: _42,
              ny: _42,
              oh: _42,
              ok: _42,
              or: _42,
              pa: _42,
              pr: _42,
              ri: _43,
              sc: _42,
              sd: _43,
              tn: _42,
              tx: _42,
              ut: _42,
              vi: _42,
              vt: _42,
              va: _42,
              wa: _42,
              wi: _42,
              wv: [
                1,
                {
                  cc: _2,
                },
              ],
              wy: _42,
              graphox: _3,
              cloudns: _3,
              drud: _3,
              "is-by": _3,
              "land-4-sale": _3,
              "stuff-4-sale": _3,
              enscaled: [
                0,
                {
                  phx: _3,
                },
              ],
              mircloud: _3,
              freeddns: _3,
              golffan: _3,
              noip: _3,
              pointto: _3,
              platterp: _3,
            },
          ],
          uy: [
            1,
            {
              com: _6,
              edu: _2,
              gub: _2,
              mil: _2,
              net: _2,
              org: _2,
            },
          ],
          uz: [
            1,
            {
              co: _2,
              com: _2,
              net: _2,
              org: _2,
            },
          ],
          va: _2,
          vc: [
            1,
            {
              com: _2,
              net: _2,
              org: _2,
              gov: _2,
              mil: _2,
              edu: _2,
              gv: [
                2,
                {
                  d: _3,
                },
              ],
              "0e": _3,
            },
          ],
          ve: [
            1,
            {
              arts: _2,
              bib: _2,
              co: _2,
              com: _2,
              e12: _2,
              edu: _2,
              firm: _2,
              gob: _2,
              gov: _2,
              info: _2,
              int: _2,
              mil: _2,
              net: _2,
              nom: _2,
              org: _2,
              rar: _2,
              rec: _2,
              store: _2,
              tec: _2,
              web: _2,
            },
          ],
          vg: [
            1,
            {
              at: _3,
            },
          ],
          vi: [
            1,
            {
              co: _2,
              com: _2,
              k12: _2,
              net: _2,
              org: _2,
            },
          ],
          vn: [
            1,
            {
              ac: _2,
              ai: _2,
              biz: _2,
              com: _2,
              edu: _2,
              gov: _2,
              health: _2,
              id: _2,
              info: _2,
              int: _2,
              io: _2,
              name: _2,
              net: _2,
              org: _2,
              pro: _2,
              angiang: _2,
              bacgiang: _2,
              backan: _2,
              baclieu: _2,
              bacninh: _2,
              "baria-vungtau": _2,
              bentre: _2,
              binhdinh: _2,
              binhduong: _2,
              binhphuoc: _2,
              binhthuan: _2,
              camau: _2,
              cantho: _2,
              caobang: _2,
              daklak: _2,
              daknong: _2,
              danang: _2,
              dienbien: _2,
              dongnai: _2,
              dongthap: _2,
              gialai: _2,
              hagiang: _2,
              haiduong: _2,
              haiphong: _2,
              hanam: _2,
              hanoi: _2,
              hatinh: _2,
              haugiang: _2,
              hoabinh: _2,
              hungyen: _2,
              khanhhoa: _2,
              kiengiang: _2,
              kontum: _2,
              laichau: _2,
              lamdong: _2,
              langson: _2,
              laocai: _2,
              longan: _2,
              namdinh: _2,
              nghean: _2,
              ninhbinh: _2,
              ninhthuan: _2,
              phutho: _2,
              phuyen: _2,
              quangbinh: _2,
              quangnam: _2,
              quangngai: _2,
              quangninh: _2,
              quangtri: _2,
              soctrang: _2,
              sonla: _2,
              tayninh: _2,
              thaibinh: _2,
              thainguyen: _2,
              thanhhoa: _2,
              thanhphohochiminh: _2,
              thuathienhue: _2,
              tiengiang: _2,
              travinh: _2,
              tuyenquang: _2,
              vinhlong: _2,
              vinhphuc: _2,
              yenbai: _2,
              blogspot: _3,
            },
          ],
          vu: [
            1,
            {
              com: _2,
              edu: _2,
              net: _2,
              org: _2,
              cn: _3,
              blog: _3,
              dev: _3,
              me: _3,
            },
          ],
          wf: [
            1,
            {
              biz: _3,
              sch: _3,
            },
          ],
          ws: [
            1,
            {
              com: _2,
              net: _2,
              org: _2,
              gov: _2,
              edu: _2,
              advisor: _5,
              cloud66: _3,
              dyndns: _3,
              mypets: _3,
            },
          ],
          yt: [
            1,
            {
              org: _3,
            },
          ],
          "xn--mgbaam7a8h": _2,
          امارات: _2,
          "xn--y9a3aq": _2,
          հայ: _2,
          "xn--54b7fta0cc": _2,
          বাংলা: _2,
          "xn--90ae": _2,
          бг: _2,
          "xn--mgbcpq6gpa1a": _2,
          البحرين: _2,
          "xn--90ais": _2,
          бел: _2,
          "xn--fiqs8s": _2,
          中国: _2,
          "xn--fiqz9s": _2,
          中國: _2,
          "xn--lgbbat1ad8j": _2,
          الجزائر: _2,
          "xn--wgbh1c": _2,
          مصر: _2,
          "xn--e1a4c": _2,
          ею: _2,
          "xn--qxa6a": _2,
          ευ: _2,
          "xn--mgbah1a3hjkrd": _2,
          موريتانيا: _2,
          "xn--node": _2,
          გე: _2,
          "xn--qxam": _2,
          ελ: _2,
          "xn--j6w193g": [
            1,
            {
              "xn--55qx5d": _2,
              "xn--wcvs22d": _2,
              "xn--mxtq1m": _2,
              "xn--gmqw5a": _2,
              "xn--od0alg": _2,
              "xn--uc0atv": _2,
            },
          ],
          香港: [
            1,
            {
              公司: _2,
              教育: _2,
              政府: _2,
              個人: _2,
              網絡: _2,
              組織: _2,
            },
          ],
          "xn--2scrj9c": _2,
          ಭಾರತ: _2,
          "xn--3hcrj9c": _2,
          ଭାରତ: _2,
          "xn--45br5cyl": _2,
          ভাৰত: _2,
          "xn--h2breg3eve": _2,
          भारतम्: _2,
          "xn--h2brj9c8c": _2,
          भारोत: _2,
          "xn--mgbgu82a": _2,
          ڀارت: _2,
          "xn--rvc1e0am3e": _2,
          ഭാരതം: _2,
          "xn--h2brj9c": _2,
          भारत: _2,
          "xn--mgbbh1a": _2,
          بارت: _2,
          "xn--mgbbh1a71e": _2,
          بھارت: _2,
          "xn--fpcrj9c3d": _2,
          భారత్: _2,
          "xn--gecrj9c": _2,
          ભારત: _2,
          "xn--s9brj9c": _2,
          ਭਾਰਤ: _2,
          "xn--45brj9c": _2,
          ভারত: _2,
          "xn--xkc2dl3a5ee0h": _2,
          இந்தியா: _2,
          "xn--mgba3a4f16a": _2,
          ایران: _2,
          "xn--mgba3a4fra": _2,
          ايران: _2,
          "xn--mgbtx2b": _2,
          عراق: _2,
          "xn--mgbayh7gpa": _2,
          الاردن: _2,
          "xn--3e0b707e": _2,
          한국: _2,
          "xn--80ao21a": _2,
          қаз: _2,
          "xn--q7ce6a": _2,
          ລາວ: _2,
          "xn--fzc2c9e2c": _2,
          ලංකා: _2,
          "xn--xkc2al3hye2a": _2,
          இலங்கை: _2,
          "xn--mgbc0a9azcg": _2,
          المغرب: _2,
          "xn--d1alf": _2,
          мкд: _2,
          "xn--l1acc": _2,
          мон: _2,
          "xn--mix891f": _2,
          澳門: _2,
          "xn--mix082f": _2,
          澳门: _2,
          "xn--mgbx4cd0ab": _2,
          مليسيا: _2,
          "xn--mgb9awbf": _2,
          عمان: _2,
          "xn--mgbai9azgqp6j": _2,
          پاکستان: _2,
          "xn--mgbai9a5eva00b": _2,
          پاكستان: _2,
          "xn--ygbi2ammx": _2,
          فلسطين: _2,
          "xn--90a3ac": [
            1,
            {
              "xn--o1ac": _2,
              "xn--c1avg": _2,
              "xn--90azh": _2,
              "xn--d1at": _2,
              "xn--o1ach": _2,
              "xn--80au": _2,
            },
          ],
          срб: [
            1,
            {
              пр: _2,
              орг: _2,
              обр: _2,
              од: _2,
              упр: _2,
              ак: _2,
            },
          ],
          "xn--p1ai": _2,
          рф: _2,
          "xn--wgbl6a": _2,
          قطر: _2,
          "xn--mgberp4a5d4ar": _2,
          السعودية: _2,
          "xn--mgberp4a5d4a87g": _2,
          السعودیة: _2,
          "xn--mgbqly7c0a67fbc": _2,
          السعودیۃ: _2,
          "xn--mgbqly7cvafr": _2,
          السعوديه: _2,
          "xn--mgbpl2fh": _2,
          سودان: _2,
          "xn--yfro4i67o": _2,
          新加坡: _2,
          "xn--clchc0ea0b2g2a9gcd": _2,
          சிங்கப்பூர்: _2,
          "xn--ogbpf8fl": _2,
          سورية: _2,
          "xn--mgbtf8fl": _2,
          سوريا: _2,
          "xn--o3cw4h": [
            1,
            {
              "xn--12c1fe0br": _2,
              "xn--12co0c3b4eva": _2,
              "xn--h3cuzk1di": _2,
              "xn--o3cyx2a": _2,
              "xn--m3ch0j3a": _2,
              "xn--12cfi8ixb8l": _2,
            },
          ],
          ไทย: [
            1,
            {
              ศึกษา: _2,
              ธุรกิจ: _2,
              รัฐบาล: _2,
              ทหาร: _2,
              เน็ต: _2,
              องค์กร: _2,
            },
          ],
          "xn--pgbs0dh": _2,
          تونس: _2,
          "xn--kpry57d": _2,
          台灣: _2,
          "xn--kprw13d": _2,
          台湾: _2,
          "xn--nnx388a": _2,
          臺灣: _2,
          "xn--j1amh": _2,
          укр: _2,
          "xn--mgb2ddes": _2,
          اليمن: _2,
          xxx: _2,
          ye: _34,
          za: [
            0,
            {
              ac: _2,
              agric: _2,
              alt: _2,
              co: _6,
              edu: _2,
              gov: _2,
              grondar: _2,
              law: _2,
              mil: _2,
              net: _2,
              ngo: _2,
              nic: _2,
              nis: _2,
              nom: _2,
              org: _2,
              school: _2,
              tm: _2,
              web: _2,
            },
          ],
          zm: [
            1,
            {
              ac: _2,
              biz: _2,
              co: _2,
              com: _2,
              edu: _2,
              gov: _2,
              info: _2,
              mil: _2,
              net: _2,
              org: _2,
              sch: _2,
            },
          ],
          zw: [
            1,
            {
              ac: _2,
              co: _2,
              gov: _2,
              mil: _2,
              org: _2,
            },
          ],
          aaa: _2,
          aarp: _2,
          abb: _2,
          abbott: _2,
          abbvie: _2,
          abc: _2,
          able: _2,
          abogado: _2,
          abudhabi: _2,
          academy: [
            1,
            {
              official: _3,
            },
          ],
          accenture: _2,
          accountant: _2,
          accountants: _2,
          aco: _2,
          actor: _2,
          ads: _2,
          adult: _2,
          aeg: _2,
          aetna: _2,
          afl: _2,
          africa: _2,
          agakhan: _2,
          agency: _2,
          aig: _2,
          airbus: _2,
          airforce: _2,
          airtel: _2,
          akdn: _2,
          alibaba: _2,
          alipay: _2,
          allfinanz: _2,
          allstate: _2,
          ally: _2,
          alsace: _2,
          alstom: _2,
          amazon: _2,
          americanexpress: _2,
          americanfamily: _2,
          amex: _2,
          amfam: _2,
          amica: _2,
          amsterdam: _2,
          analytics: _2,
          android: _2,
          anquan: _2,
          anz: _2,
          aol: _2,
          apartments: _2,
          app: [
            1,
            {
              beget: _5,
              clerk: _3,
              clerkstage: _3,
              wnext: _3,
              platform0: _3,
              deta: _3,
              ondigitalocean: _3,
              easypanel: _3,
              encr: _3,
              edgecompute: _3,
              fireweb: _3,
              onflashdrive: _3,
              framer: _3,
              run: [
                2,
                {
                  a: _3,
                },
              ],
              web: _3,
              hasura: _3,
              loginline: _3,
              messerli: _3,
              netlify: _3,
              ngrok: _3,
              "ngrok-free": _3,
              developer: _5,
              noop: _3,
              northflank: _5,
              snowflake: [
                2,
                {
                  privatelink: _3,
                },
              ],
              streamlit: _3,
              storipress: _3,
              telebit: _3,
              typedream: _3,
              vercel: _3,
              bookonline: _3,
            },
          ],
          apple: _2,
          aquarelle: _2,
          arab: _2,
          aramco: _2,
          archi: _2,
          army: _2,
          art: _2,
          arte: _2,
          asda: _2,
          associates: _2,
          athleta: _2,
          attorney: _2,
          auction: _2,
          audi: _2,
          audible: _2,
          audio: _2,
          auspost: _2,
          author: _2,
          auto: _2,
          autos: _2,
          avianca: _2,
          aws: _2,
          axa: _2,
          azure: _2,
          baby: _2,
          baidu: _2,
          banamex: _2,
          bananarepublic: _2,
          band: _2,
          bank: _2,
          bar: _2,
          barcelona: _2,
          barclaycard: _2,
          barclays: _2,
          barefoot: _2,
          bargains: _2,
          baseball: _2,
          basketball: [
            1,
            {
              aus: _3,
              nz: _3,
            },
          ],
          bauhaus: _2,
          bayern: _2,
          bbc: _2,
          bbt: _2,
          bbva: _2,
          bcg: _2,
          bcn: _2,
          beats: _2,
          beauty: _2,
          beer: _2,
          bentley: _2,
          berlin: _2,
          best: _2,
          bestbuy: _2,
          bet: _2,
          bharti: _2,
          bible: _2,
          bid: _2,
          bike: _2,
          bing: _2,
          bingo: _2,
          bio: _2,
          black: _2,
          blackfriday: _2,
          blockbuster: _2,
          blog: _2,
          bloomberg: _2,
          blue: _2,
          bms: _2,
          bmw: _2,
          bnpparibas: _2,
          boats: _2,
          boehringer: _2,
          bofa: _2,
          bom: _2,
          bond: _2,
          boo: _2,
          book: _2,
          booking: _2,
          bosch: _2,
          bostik: _2,
          boston: _2,
          bot: _2,
          boutique: _2,
          box: _2,
          bradesco: _2,
          bridgestone: _2,
          broadway: _2,
          broker: _2,
          brother: _2,
          brussels: _2,
          build: _2,
          builders: [
            1,
            {
              cloudsite: _3,
            },
          ],
          business: _10,
          buy: _2,
          buzz: _2,
          bzh: _2,
          cab: _2,
          cafe: _2,
          cal: _2,
          call: _2,
          calvinklein: _2,
          cam: _2,
          camera: _2,
          camp: _2,
          canon: _2,
          capetown: _2,
          capital: _2,
          capitalone: _2,
          car: _2,
          caravan: _2,
          cards: _2,
          care: _2,
          career: _2,
          careers: _2,
          cars: _2,
          casa: [
            1,
            {
              nabu: [
                0,
                {
                  ui: _3,
                },
              ],
            },
          ],
          case: _2,
          cash: _2,
          casino: _2,
          catering: _2,
          catholic: _2,
          cba: _2,
          cbn: _2,
          cbre: _2,
          cbs: _2,
          center: _2,
          ceo: _2,
          cern: _2,
          cfa: _2,
          cfd: _2,
          chanel: _2,
          channel: _2,
          charity: _2,
          chase: _2,
          chat: _2,
          cheap: _2,
          chintai: _2,
          christmas: _2,
          chrome: _2,
          church: _2,
          cipriani: _2,
          circle: _2,
          cisco: _2,
          citadel: _2,
          citi: _2,
          citic: _2,
          city: _2,
          cityeats: _2,
          claims: _2,
          cleaning: _2,
          click: _2,
          clinic: _2,
          clinique: _2,
          clothing: _2,
          cloud: [
            1,
            {
              banzai: _5,
              elementor: _3,
              encoway: [
                0,
                {
                  eu: _3,
                },
              ],
              statics: _5,
              ravendb: _3,
              axarnet: [
                0,
                {
                  "es-1": _3,
                },
              ],
              diadem: _3,
              jelastic: [
                0,
                {
                  vip: _3,
                },
              ],
              jele: _3,
              "jenv-aruba": [
                0,
                {
                  aruba: [
                    0,
                    {
                      eur: [
                        0,
                        {
                          it1: _3,
                        },
                      ],
                    },
                  ],
                  it1: _3,
                },
              ],
              keliweb: [
                2,
                {
                  cs: _3,
                },
              ],
              oxa: [
                2,
                {
                  tn: _3,
                  uk: _3,
                },
              ],
              primetel: [
                2,
                {
                  uk: _3,
                },
              ],
              reclaim: [
                0,
                {
                  ca: _3,
                  uk: _3,
                  us: _3,
                },
              ],
              trendhosting: [
                0,
                {
                  ch: _3,
                  de: _3,
                },
              ],
              jotelulu: _3,
              kuleuven: _3,
              linkyard: _3,
              magentosite: _5,
              perspecta: _3,
              vapor: _3,
              "on-rancher": _5,
              scw: [
                0,
                {
                  baremetal: [
                    0,
                    {
                      "fr-par-1": _3,
                      "fr-par-2": _3,
                      "nl-ams-1": _3,
                    },
                  ],
                  "fr-par": [
                    0,
                    {
                      fnc: [
                        2,
                        {
                          functions: _3,
                        },
                      ],
                      k8s: _11,
                      s3: _3,
                      "s3-website": _3,
                      whm: _3,
                    },
                  ],
                  instances: [
                    0,
                    {
                      priv: _3,
                      pub: _3,
                    },
                  ],
                  k8s: _3,
                  "nl-ams": [
                    0,
                    {
                      k8s: _11,
                      s3: _3,
                      "s3-website": _3,
                      whm: _3,
                    },
                  ],
                  "pl-waw": [
                    0,
                    {
                      k8s: _11,
                      s3: _3,
                      "s3-website": _3,
                    },
                  ],
                  scalebook: _3,
                  smartlabeling: _3,
                },
              ],
              sensiosite: _5,
              trafficplex: _3,
              urown: _3,
              voorloper: _3,
            },
          ],
          club: [
            1,
            {
              cloudns: _3,
              jele: _3,
              barsy: _3,
            },
          ],
          clubmed: _2,
          coach: _2,
          codes: [
            1,
            {
              owo: _5,
            },
          ],
          coffee: _2,
          college: _2,
          cologne: _2,
          comcast: _2,
          commbank: _2,
          community: [
            1,
            {
              nog: _3,
              ravendb: _3,
              myforum: _3,
            },
          ],
          company: _2,
          compare: _2,
          computer: _2,
          comsec: _2,
          condos: _2,
          construction: _2,
          consulting: _2,
          contact: _2,
          contractors: _2,
          cooking: _2,
          cool: [
            1,
            {
              elementor: _3,
              de: _3,
            },
          ],
          corsica: _2,
          country: _2,
          coupon: _2,
          coupons: _2,
          courses: _2,
          cpa: _2,
          credit: _2,
          creditcard: _2,
          creditunion: _2,
          cricket: _2,
          crown: _2,
          crs: _2,
          cruise: _2,
          cruises: _2,
          cuisinella: _2,
          cymru: _2,
          cyou: _2,
          dabur: _2,
          dad: _2,
          dance: _2,
          data: _2,
          date: _2,
          dating: _2,
          datsun: _2,
          day: _2,
          dclk: _2,
          dds: _2,
          deal: _2,
          dealer: _2,
          deals: _2,
          degree: _2,
          delivery: _2,
          dell: _2,
          deloitte: _2,
          delta: _2,
          democrat: _2,
          dental: _2,
          dentist: _2,
          desi: _2,
          design: [
            1,
            {
              bss: _3,
            },
          ],
          dev: [
            1,
            {
              autocode: _3,
              lcl: _5,
              lclstage: _5,
              stg: _5,
              stgstage: _5,
              pages: _3,
              r2: _3,
              workers: _3,
              curv: _3,
              deno: _3,
              "deno-staging": _3,
              deta: _3,
              fly: _3,
              githubpreview: _3,
              gateway: _5,
              iserv: _3,
              localcert: [
                0,
                {
                  user: _5,
                },
              ],
              loginline: _3,
              mediatech: _3,
              ngrok: _3,
              "ngrok-free": _3,
              "platter-app": _3,
              shiftcrypto: _3,
              vercel: _3,
              webhare: _5,
            },
          ],
          dhl: _2,
          diamonds: _2,
          diet: _2,
          digital: [
            1,
            {
              cloudapps: [
                2,
                {
                  london: _3,
                },
              ],
            },
          ],
          direct: _2,
          directory: _2,
          discount: _2,
          discover: _2,
          dish: _2,
          diy: _2,
          dnp: _2,
          docs: _2,
          doctor: _2,
          dog: _2,
          domains: _2,
          dot: _2,
          download: _2,
          drive: _2,
          dtv: _2,
          dubai: _2,
          dunlop: _2,
          dupont: _2,
          durban: _2,
          dvag: _2,
          dvr: _2,
          earth: [
            1,
            {
              dapps: [
                0,
                {
                  "*": _3,
                  bzz: _5,
                },
              ],
            },
          ],
          eat: _2,
          eco: _2,
          edeka: _2,
          education: _10,
          email: _2,
          emerck: _2,
          energy: _2,
          engineer: _2,
          engineering: _2,
          enterprises: _2,
          epson: _2,
          equipment: _2,
          ericsson: _2,
          erni: _2,
          esq: _2,
          estate: [
            1,
            {
              compute: _5,
            },
          ],
          etisalat: _2,
          eurovision: _2,
          eus: [
            1,
            {
              party: _30,
            },
          ],
          events: [
            1,
            {
              koobin: _3,
              co: _3,
            },
          ],
          exchange: _2,
          expert: _2,
          exposed: _2,
          express: _2,
          extraspace: _2,
          fage: _2,
          fail: _2,
          fairwinds: _2,
          faith: _31,
          family: _2,
          fan: _2,
          fans: _2,
          farm: [
            1,
            {
              storj: _3,
            },
          ],
          farmers: _2,
          fashion: _2,
          fast: _2,
          fedex: _2,
          feedback: _2,
          ferrari: _2,
          ferrero: _2,
          fidelity: _2,
          fido: _2,
          film: _2,
          final: _2,
          finance: _2,
          financial: _10,
          fire: _2,
          firestone: _2,
          firmdale: _2,
          fish: _2,
          fishing: _2,
          fit: _2,
          fitness: _2,
          flickr: _2,
          flights: _2,
          flir: _2,
          florist: _2,
          flowers: _2,
          fly: _2,
          foo: _2,
          food: _2,
          football: _2,
          ford: _2,
          forex: _2,
          forsale: _2,
          forum: _2,
          foundation: _2,
          fox: _2,
          free: _2,
          fresenius: _2,
          frl: _2,
          frogans: _2,
          frontdoor: _2,
          frontier: _2,
          ftr: _2,
          fujitsu: _2,
          fun: _2,
          fund: _2,
          furniture: _2,
          futbol: _2,
          fyi: _2,
          gal: _2,
          gallery: _2,
          gallo: _2,
          gallup: _2,
          game: _2,
          games: _2,
          gap: _2,
          garden: _2,
          gay: _2,
          gbiz: _2,
          gdn: [
            1,
            {
              cnpy: _3,
            },
          ],
          gea: _2,
          gent: _2,
          genting: _2,
          george: _2,
          ggee: _2,
          gift: _2,
          gifts: _2,
          gives: _2,
          giving: _2,
          glass: _2,
          gle: _2,
          global: _2,
          globo: _2,
          gmail: _2,
          gmbh: _2,
          gmo: _2,
          gmx: _2,
          godaddy: _2,
          gold: _2,
          goldpoint: _2,
          golf: _2,
          goo: _2,
          goodyear: _2,
          goog: [
            1,
            {
              cloud: _3,
              translate: _3,
              usercontent: _5,
            },
          ],
          google: _2,
          gop: _2,
          got: _2,
          grainger: _2,
          graphics: _2,
          gratis: _2,
          green: _2,
          gripe: _2,
          grocery: _2,
          group: [
            1,
            {
              discourse: _3,
            },
          ],
          guardian: _2,
          gucci: _2,
          guge: _2,
          guide: _2,
          guitars: _2,
          guru: _2,
          hair: _2,
          hamburg: _2,
          hangout: _2,
          haus: _2,
          hbo: _2,
          hdfc: _2,
          hdfcbank: _2,
          health: [
            1,
            {
              hra: _3,
            },
          ],
          healthcare: _2,
          help: _2,
          helsinki: _2,
          here: _2,
          hermes: _2,
          hiphop: _2,
          hisamitsu: _2,
          hitachi: _2,
          hiv: _2,
          hkt: _2,
          hockey: _2,
          holdings: _2,
          holiday: _2,
          homedepot: _2,
          homegoods: _2,
          homes: _2,
          homesense: _2,
          honda: _2,
          horse: _2,
          hospital: _2,
          host: [
            1,
            {
              cloudaccess: _3,
              freesite: _3,
              easypanel: _3,
              fastvps: _3,
              myfast: _3,
              tempurl: _3,
              wpmudev: _3,
              jele: _3,
              mircloud: _3,
              pcloud: _3,
              half: _3,
            },
          ],
          hosting: [
            1,
            {
              opencraft: _3,
            },
          ],
          hot: _2,
          hotels: _2,
          hotmail: _2,
          house: _2,
          how: _2,
          hsbc: _2,
          hughes: _2,
          hyatt: _2,
          hyundai: _2,
          ibm: _2,
          icbc: _2,
          ice: _2,
          icu: _2,
          ieee: _2,
          ifm: _2,
          ikano: _2,
          imamat: _2,
          imdb: _2,
          immo: _2,
          immobilien: _2,
          inc: _2,
          industries: _2,
          infiniti: _2,
          ing: _2,
          ink: _2,
          institute: _2,
          insurance: _2,
          insure: _2,
          international: _2,
          intuit: _2,
          investments: _2,
          ipiranga: _2,
          irish: _2,
          ismaili: _2,
          ist: _2,
          istanbul: _2,
          itau: _2,
          itv: _2,
          jaguar: _2,
          java: _2,
          jcb: _2,
          jeep: _2,
          jetzt: _2,
          jewelry: _2,
          jio: _2,
          jll: _2,
          jmp: _2,
          jnj: _2,
          joburg: _2,
          jot: _2,
          joy: _2,
          jpmorgan: _2,
          jprs: _2,
          juegos: _2,
          juniper: _2,
          kaufen: _2,
          kddi: _2,
          kerryhotels: _2,
          kerrylogistics: _2,
          kerryproperties: _2,
          kfh: _2,
          kia: _2,
          kids: _2,
          kim: _2,
          kinder: _2,
          kindle: _2,
          kitchen: _2,
          kiwi: _2,
          koeln: _2,
          komatsu: _2,
          kosher: _2,
          kpmg: _2,
          kpn: _2,
          krd: [
            1,
            {
              co: _3,
              edu: _3,
            },
          ],
          kred: _2,
          kuokgroup: _2,
          kyoto: _2,
          lacaixa: _2,
          lamborghini: _2,
          lamer: _2,
          lancaster: _2,
          land: [
            1,
            {
              static: [
                2,
                {
                  dev: _3,
                  sites: _3,
                },
              ],
            },
          ],
          landrover: _2,
          lanxess: _2,
          lasalle: _2,
          lat: _2,
          latino: _2,
          latrobe: _2,
          law: _2,
          lawyer: _2,
          lds: _2,
          lease: _2,
          leclerc: _2,
          lefrak: _2,
          legal: _2,
          lego: _2,
          lexus: _2,
          lgbt: _2,
          lidl: _2,
          life: _2,
          lifeinsurance: _2,
          lifestyle: _2,
          lighting: _2,
          like: _2,
          lilly: _2,
          limited: _2,
          limo: _2,
          lincoln: _2,
          link: [
            1,
            {
              cyon: _3,
              mypep: _3,
              dweb: _5,
            },
          ],
          lipsy: _2,
          live: [
            1,
            {
              hlx: _3,
            },
          ],
          living: _2,
          llc: _2,
          llp: _2,
          loan: _2,
          loans: _2,
          locker: _2,
          locus: _2,
          lol: [
            1,
            {
              omg: _3,
            },
          ],
          london: _2,
          lotte: _2,
          lotto: _2,
          love: _2,
          lpl: _2,
          lplfinancial: _2,
          ltd: _2,
          ltda: _2,
          lundbeck: _2,
          luxe: _2,
          luxury: _2,
          madrid: _2,
          maif: _2,
          maison: _2,
          makeup: _2,
          man: _2,
          management: [
            1,
            {
              router: _3,
            },
          ],
          mango: _2,
          map: _2,
          market: _2,
          marketing: _2,
          markets: _2,
          marriott: _2,
          marshalls: _2,
          mattel: _2,
          mba: _2,
          mckinsey: _2,
          med: _2,
          media: _37,
          meet: _2,
          melbourne: _2,
          meme: _2,
          memorial: _2,
          men: _2,
          menu: _38,
          merckmsd: _2,
          miami: _2,
          microsoft: _2,
          mini: _2,
          mint: _2,
          mit: _2,
          mitsubishi: _2,
          mlb: _2,
          mls: _2,
          mma: _2,
          mobile: _2,
          moda: _2,
          moe: _2,
          moi: _2,
          mom: _2,
          monash: _2,
          money: _2,
          monster: _2,
          mormon: _2,
          mortgage: _2,
          moscow: _2,
          moto: _2,
          motorcycles: _2,
          mov: _2,
          movie: _2,
          msd: _2,
          mtn: _2,
          mtr: _2,
          music: _2,
          nab: _2,
          nagoya: _2,
          natura: _2,
          navy: _2,
          nba: _2,
          nec: _2,
          netbank: _2,
          netflix: _2,
          network: [
            1,
            {
              alces: _5,
              co: _3,
              arvo: _3,
              azimuth: _3,
              tlon: _3,
            },
          ],
          neustar: _2,
          new: _2,
          news: [
            1,
            {
              noticeable: _3,
            },
          ],
          next: _2,
          nextdirect: _2,
          nexus: _2,
          nfl: _2,
          ngo: _2,
          nhk: _2,
          nico: _2,
          nike: _2,
          nikon: _2,
          ninja: _2,
          nissan: _2,
          nissay: _2,
          nokia: _2,
          norton: _2,
          now: _2,
          nowruz: _2,
          nowtv: _2,
          nra: _2,
          nrw: _2,
          ntt: _2,
          nyc: _2,
          obi: _2,
          observer: _2,
          office: _2,
          okinawa: _2,
          olayan: _2,
          olayangroup: _2,
          oldnavy: _2,
          ollo: _2,
          omega: _2,
          one: [
            1,
            {
              onred: [
                2,
                {
                  staging: _3,
                },
              ],
              service: _3,
              homelink: _3,
            },
          ],
          ong: _2,
          onl: _2,
          online: [
            1,
            {
              eero: _3,
              "eero-stage": _3,
              barsy: _3,
            },
          ],
          ooo: _2,
          open: _2,
          oracle: _2,
          orange: [
            1,
            {
              tech: _3,
            },
          ],
          organic: _2,
          origins: _2,
          osaka: _2,
          otsuka: _2,
          ott: _2,
          ovh: [
            1,
            {
              nerdpol: _3,
            },
          ],
          page: [
            1,
            {
              hlx: _3,
              hlx3: _3,
              translated: _3,
              codeberg: _3,
              pdns: _3,
              plesk: _3,
              prvcy: _3,
              rocky: _3,
              magnet: _3,
            },
          ],
          panasonic: _2,
          paris: _2,
          pars: _2,
          partners: _2,
          parts: _2,
          party: _31,
          pay: _2,
          pccw: _2,
          pet: _2,
          pfizer: _2,
          pharmacy: _2,
          phd: _2,
          philips: _2,
          phone: _2,
          photo: _2,
          photography: _2,
          photos: _37,
          physio: _2,
          pics: _2,
          pictet: _2,
          pictures: [
            1,
            {
              1337: _3,
            },
          ],
          pid: _2,
          pin: _2,
          ping: _2,
          pink: _2,
          pioneer: _2,
          pizza: [
            1,
            {
              ngrok: _3,
            },
          ],
          place: _10,
          play: _2,
          playstation: _2,
          plumbing: _2,
          plus: _2,
          pnc: _2,
          pohl: _2,
          poker: _2,
          politie: _2,
          porn: [
            1,
            {
              indie: _3,
            },
          ],
          pramerica: _2,
          praxi: _2,
          press: _2,
          prime: _2,
          prod: _2,
          productions: _2,
          prof: _2,
          progressive: _2,
          promo: _2,
          properties: _2,
          property: _2,
          protection: _2,
          pru: _2,
          prudential: _2,
          pub: _38,
          pwc: _2,
          qpon: _2,
          quebec: _2,
          quest: _2,
          racing: _2,
          radio: _2,
          read: _2,
          realestate: _2,
          realtor: _2,
          realty: _2,
          recipes: _2,
          red: _2,
          redstone: _2,
          redumbrella: _2,
          rehab: _2,
          reise: _2,
          reisen: _2,
          reit: _2,
          reliance: _2,
          ren: _2,
          rent: _2,
          rentals: _2,
          repair: _2,
          report: _2,
          republican: _2,
          rest: _2,
          restaurant: _2,
          review: _31,
          reviews: _2,
          rexroth: _2,
          rich: _2,
          richardli: _2,
          ricoh: _2,
          ril: _2,
          rio: _2,
          rip: [
            1,
            {
              clan: _3,
            },
          ],
          rocher: _2,
          rocks: [
            1,
            {
              myddns: _3,
              "lima-city": _3,
              webspace: _3,
            },
          ],
          rodeo: _2,
          rogers: _2,
          room: _2,
          rsvp: _2,
          rugby: _2,
          ruhr: _2,
          run: [
            1,
            {
              hs: _3,
              development: _3,
              ravendb: _3,
              servers: _3,
              build: _5,
              code: _5,
              database: _5,
              migration: _5,
              onporter: _3,
              repl: _3,
            },
          ],
          rwe: _2,
          ryukyu: _2,
          saarland: _2,
          safe: _2,
          safety: _2,
          sakura: _2,
          sale: _2,
          salon: _2,
          samsclub: _2,
          samsung: _2,
          sandvik: _2,
          sandvikcoromant: _2,
          sanofi: _2,
          sap: _2,
          sarl: _2,
          sas: _2,
          save: _2,
          saxo: _2,
          sbi: _2,
          sbs: _2,
          sca: _2,
          scb: _2,
          schaeffler: _2,
          schmidt: _2,
          scholarships: _2,
          school: _2,
          schule: _2,
          schwarz: _2,
          science: _31,
          scot: [
            1,
            {
              edu: _3,
              gov: [
                2,
                {
                  service: _3,
                },
              ],
            },
          ],
          search: _2,
          seat: _2,
          secure: _2,
          security: _2,
          seek: _2,
          select: _2,
          sener: _2,
          services: [
            1,
            {
              loginline: _3,
            },
          ],
          seven: _2,
          sew: _2,
          sex: _2,
          sexy: _2,
          sfr: _2,
          shangrila: _2,
          sharp: _2,
          shaw: _2,
          shell: _2,
          shia: _2,
          shiksha: _2,
          shoes: _2,
          shop: [
            1,
            {
              base: _3,
              hoplix: _3,
              barsy: _3,
            },
          ],
          shopping: _2,
          shouji: _2,
          show: _2,
          showtime: _2,
          silk: _2,
          sina: _2,
          singles: _2,
          site: [
            1,
            {
              cloudera: _5,
              cyon: _3,
              fnwk: _3,
              folionetwork: _3,
              fastvps: _3,
              jele: _3,
              lelux: _3,
              loginline: _3,
              barsy: _3,
              mintere: _3,
              omniwe: _3,
              opensocial: _3,
              platformsh: _5,
              tst: _5,
              byen: _3,
              srht: _3,
              novecore: _3,
            },
          ],
          ski: _2,
          skin: _2,
          sky: _2,
          skype: _2,
          sling: _2,
          smart: _2,
          smile: _2,
          sncf: _2,
          soccer: _2,
          social: _2,
          softbank: _2,
          software: _2,
          sohu: _2,
          solar: _2,
          solutions: [
            1,
            {
              diher: _5,
            },
          ],
          song: _2,
          sony: _2,
          soy: _2,
          spa: _2,
          space: [
            1,
            {
              myfast: _3,
              uber: _3,
              xs4all: _3,
            },
          ],
          sport: _2,
          spot: _2,
          srl: _2,
          stada: _2,
          staples: _2,
          star: _2,
          statebank: _2,
          statefarm: _2,
          stc: _2,
          stcgroup: _2,
          stockholm: _2,
          storage: _2,
          store: [
            1,
            {
              sellfy: _3,
              shopware: _3,
              storebase: _3,
            },
          ],
          stream: _2,
          studio: _2,
          study: _2,
          style: _2,
          sucks: _2,
          supplies: _2,
          supply: _2,
          support: _38,
          surf: _2,
          surgery: _2,
          suzuki: _2,
          swatch: _2,
          swiss: _2,
          sydney: _2,
          systems: [
            1,
            {
              knightpoint: _3,
            },
          ],
          tab: _2,
          taipei: _2,
          talk: _2,
          taobao: _2,
          target: _2,
          tatamotors: _2,
          tatar: _2,
          tattoo: _2,
          tax: _2,
          taxi: _2,
          tci: _2,
          tdk: _2,
          team: [
            1,
            {
              discourse: _3,
              jelastic: _3,
            },
          ],
          tech: _2,
          technology: _10,
          temasek: _2,
          tennis: _2,
          teva: _2,
          thd: _2,
          theater: _2,
          theatre: _2,
          tiaa: _2,
          tickets: _2,
          tienda: _2,
          tips: _2,
          tires: _2,
          tirol: _2,
          tjmaxx: _2,
          tjx: _2,
          tkmaxx: _2,
          tmall: _2,
          today: [
            1,
            {
              prequalifyme: _3,
            },
          ],
          tokyo: _2,
          tools: _2,
          top: [
            1,
            {
              "now-dns": _3,
              ntdll: _3,
            },
          ],
          toray: _2,
          toshiba: _2,
          total: _2,
          tours: _2,
          town: _2,
          toyota: _2,
          toys: _2,
          trade: _31,
          trading: _2,
          training: _2,
          travel: _2,
          travelers: _2,
          travelersinsurance: _2,
          trust: _2,
          trv: _2,
          tube: _2,
          tui: _2,
          tunes: _2,
          tushu: _2,
          tvs: _2,
          ubank: _2,
          ubs: _2,
          unicom: _2,
          university: _2,
          uno: _2,
          uol: _2,
          ups: _2,
          vacations: _2,
          vana: _2,
          vanguard: _2,
          vegas: _2,
          ventures: _2,
          verisign: _2,
          versicherung: _2,
          vet: _2,
          viajes: _2,
          video: _2,
          vig: _2,
          viking: _2,
          villas: _2,
          vin: _2,
          vip: _2,
          virgin: _2,
          visa: _2,
          vision: _2,
          viva: _2,
          vivo: _2,
          vlaanderen: _2,
          vodka: _2,
          volkswagen: _2,
          volvo: _2,
          vote: _2,
          voting: _2,
          voto: _2,
          voyage: _2,
          wales: _2,
          walmart: _2,
          walter: _2,
          wang: _2,
          wanggou: _2,
          watch: _2,
          watches: _2,
          weather: _2,
          weatherchannel: _2,
          webcam: _2,
          weber: _2,
          website: _37,
          wedding: _2,
          weibo: _2,
          weir: _2,
          whoswho: _2,
          wien: _2,
          wiki: _37,
          williamhill: _2,
          win: _2,
          windows: _2,
          wine: _2,
          winners: _2,
          wme: _2,
          wolterskluwer: _2,
          woodside: _2,
          work: _2,
          works: _2,
          world: _2,
          wow: _2,
          wtc: _2,
          wtf: _2,
          xbox: _2,
          xerox: _2,
          xfinity: _2,
          xihuan: _2,
          xin: _2,
          "xn--11b4c3d": _2,
          कॉम: _2,
          "xn--1ck2e1b": _2,
          セール: _2,
          "xn--1qqw23a": _2,
          佛山: _2,
          "xn--30rr7y": _2,
          慈善: _2,
          "xn--3bst00m": _2,
          集团: _2,
          "xn--3ds443g": _2,
          在线: _2,
          "xn--3pxu8k": _2,
          点看: _2,
          "xn--42c2d9a": _2,
          คอม: _2,
          "xn--45q11c": _2,
          八卦: _2,
          "xn--4gbrim": _2,
          موقع: _2,
          "xn--55qw42g": _2,
          公益: _2,
          "xn--55qx5d": _2,
          公司: _2,
          "xn--5su34j936bgsg": _2,
          香格里拉: _2,
          "xn--5tzm5g": _2,
          网站: _2,
          "xn--6frz82g": _2,
          移动: _2,
          "xn--6qq986b3xl": _2,
          我爱你: _2,
          "xn--80adxhks": _2,
          москва: _2,
          "xn--80aqecdr1a": _2,
          католик: _2,
          "xn--80asehdb": _2,
          онлайн: _2,
          "xn--80aswg": _2,
          сайт: _2,
          "xn--8y0a063a": _2,
          联通: _2,
          "xn--9dbq2a": _2,
          קום: _2,
          "xn--9et52u": _2,
          时尚: _2,
          "xn--9krt00a": _2,
          微博: _2,
          "xn--b4w605ferd": _2,
          淡马锡: _2,
          "xn--bck1b9a5dre4c": _2,
          ファッション: _2,
          "xn--c1avg": _2,
          орг: _2,
          "xn--c2br7g": _2,
          नेट: _2,
          "xn--cck2b3b": _2,
          ストア: _2,
          "xn--cckwcxetd": _2,
          アマゾン: _2,
          "xn--cg4bki": _2,
          삼성: _2,
          "xn--czr694b": _2,
          商标: _2,
          "xn--czrs0t": _2,
          商店: _2,
          "xn--czru2d": _2,
          商城: _2,
          "xn--d1acj3b": _2,
          дети: _2,
          "xn--eckvdtc9d": _2,
          ポイント: _2,
          "xn--efvy88h": _2,
          新闻: _2,
          "xn--fct429k": _2,
          家電: _2,
          "xn--fhbei": _2,
          كوم: _2,
          "xn--fiq228c5hs": _2,
          中文网: _2,
          "xn--fiq64b": _2,
          中信: _2,
          "xn--fjq720a": _2,
          娱乐: _2,
          "xn--flw351e": _2,
          谷歌: _2,
          "xn--fzys8d69uvgm": _2,
          電訊盈科: _2,
          "xn--g2xx48c": _2,
          购物: _2,
          "xn--gckr3f0f": _2,
          クラウド: _2,
          "xn--gk3at1e": _2,
          通販: _2,
          "xn--hxt814e": _2,
          网店: _2,
          "xn--i1b6b1a6a2e": _2,
          संगठन: _2,
          "xn--imr513n": _2,
          餐厅: _2,
          "xn--io0a7i": _2,
          网络: _2,
          "xn--j1aef": _2,
          ком: _2,
          "xn--jlq480n2rg": _2,
          亚马逊: _2,
          "xn--jvr189m": _2,
          食品: _2,
          "xn--kcrx77d1x4a": _2,
          飞利浦: _2,
          "xn--kput3i": _2,
          手机: _2,
          "xn--mgba3a3ejt": _2,
          ارامكو: _2,
          "xn--mgba7c0bbn0a": _2,
          العليان: _2,
          "xn--mgbaakc7dvf": _2,
          اتصالات: _2,
          "xn--mgbab2bd": _2,
          بازار: _2,
          "xn--mgbca7dzdo": _2,
          ابوظبي: _2,
          "xn--mgbi4ecexp": _2,
          كاثوليك: _2,
          "xn--mgbt3dhd": _2,
          همراه: _2,
          "xn--mk1bu44c": _2,
          닷컴: _2,
          "xn--mxtq1m": _2,
          政府: _2,
          "xn--ngbc5azd": _2,
          شبكة: _2,
          "xn--ngbe9e0a": _2,
          بيتك: _2,
          "xn--ngbrx": _2,
          عرب: _2,
          "xn--nqv7f": _2,
          机构: _2,
          "xn--nqv7fs00ema": _2,
          组织机构: _2,
          "xn--nyqy26a": _2,
          健康: _2,
          "xn--otu796d": _2,
          招聘: _2,
          "xn--p1acf": [
            1,
            {
              "xn--90amc": _3,
              "xn--j1aef": _3,
              "xn--j1ael8b": _3,
              "xn--h1ahn": _3,
              "xn--j1adp": _3,
              "xn--c1avg": _3,
              "xn--80aaa0cvac": _3,
              "xn--h1aliz": _3,
              "xn--90a1af": _3,
              "xn--41a": _3,
            },
          ],
          рус: [
            1,
            {
              биз: _3,
              ком: _3,
              крым: _3,
              мир: _3,
              мск: _3,
              орг: _3,
              самара: _3,
              сочи: _3,
              спб: _3,
              я: _3,
            },
          ],
          "xn--pssy2u": _2,
          大拿: _2,
          "xn--q9jyb4c": _2,
          みんな: _2,
          "xn--qcka1pmc": _2,
          グーグル: _2,
          "xn--rhqv96g": _2,
          世界: _2,
          "xn--rovu88b": _2,
          書籍: _2,
          "xn--ses554g": _2,
          网址: _2,
          "xn--t60b56a": _2,
          닷넷: _2,
          "xn--tckwe": _2,
          コム: _2,
          "xn--tiq49xqyj": _2,
          天主教: _2,
          "xn--unup4y": _2,
          游戏: _2,
          "xn--vermgensberater-ctb": _2,
          vermögensberater: _2,
          "xn--vermgensberatung-pwb": _2,
          vermögensberatung: _2,
          "xn--vhquv": _2,
          企业: _2,
          "xn--vuq861b": _2,
          信息: _2,
          "xn--w4r85el8fhu5dnra": _2,
          嘉里大酒店: _2,
          "xn--w4rs40l": _2,
          嘉里: _2,
          "xn--xhq521b": _2,
          广东: _2,
          "xn--zfr164b": _2,
          政务: _2,
          xyz: [
            1,
            {
              blogsite: _3,
              localzone: _3,
              crafting: _3,
              zapto: _3,
              telebit: _5,
            },
          ],
          yachts: _2,
          yahoo: _2,
          yamaxun: _2,
          yandex: _2,
          yodobashi: _2,
          yoga: _2,
          yokohama: _2,
          you: _2,
          youtube: _2,
          yun: _2,
          zappos: _2,
          zara: _2,
          zero: _2,
          zip: _2,
          zone: [
            1,
            {
              cloud66: _3,
              hs: _3,
              triton: _5,
              lima: _3,
            },
          ],
          zuerich: _2,
        },
      ]
      return rules
    })() // CONCATENATED MODULE: ../../node_modules/tldts/dist/es6/src/suffix-trie.js
    /**
     * Lookup parts of domain in Trie
     */
    function lookupInTrie(parts, trie, index, allowedMask) {
      let result = null
      let node = trie
      while (node !== undefined) {
        // We have a match!
        if ((node[0] & allowedMask) !== 0) {
          result = {
            index: index + 1,
            isIcann: node[0] === 1 /* RULE_TYPE.ICANN */,
            isPrivate: node[0] === 2 /* RULE_TYPE.PRIVATE */,
          }
        }
        // No more `parts` to look for
        if (index === -1) {
          break
        }
        const succ = node[1]
        node = Object.prototype.hasOwnProperty.call(succ, parts[index])
          ? succ[parts[index]]
          : succ["*"]
        index -= 1
      }
      return result
    }
    /**
     * Check if `hostname` has a valid public suffix in `trie`.
     */
    function suffix_trie_suffixLookup(hostname, options, out) {
      var _a
      if (fast_path(hostname, options, out)) {
        return
      }
      const hostnameParts = hostname.split(".")
      const allowedMask =
        (options.allowPrivateDomains ? 2 /* RULE_TYPE.PRIVATE */ : 0) |
        (options.allowIcannDomains ? 1 /* RULE_TYPE.ICANN */ : 0)
      // Look for exceptions
      const exceptionMatch = lookupInTrie(
        hostnameParts,
        exceptions,
        hostnameParts.length - 1,
        allowedMask,
      )
      if (exceptionMatch !== null) {
        out.isIcann = exceptionMatch.isIcann
        out.isPrivate = exceptionMatch.isPrivate
        out.publicSuffix = hostnameParts
          .slice(exceptionMatch.index + 1)
          .join(".")
        return
      }
      // Look for a match in rules
      const rulesMatch = lookupInTrie(
        hostnameParts,
        rules,
        hostnameParts.length - 1,
        allowedMask,
      )
      if (rulesMatch !== null) {
        out.isIcann = rulesMatch.isIcann
        out.isPrivate = rulesMatch.isPrivate
        out.publicSuffix = hostnameParts.slice(rulesMatch.index).join(".")
        return
      }
      // No match found...
      // Prevailing rule is '*' so we consider the top-level domain to be the
      // public suffix of `hostname` (e.g.: 'example.org' => 'org').
      out.isIcann = false
      out.isPrivate = false
      out.publicSuffix =
        (_a = hostnameParts[hostnameParts.length - 1]) !== null && _a !== void 0
          ? _a
          : null
    } // CONCATENATED MODULE: ../../node_modules/tldts/dist/es6/index.js
    // For all methods but 'parse', it does not make sense to allocate an object
    // every single time to only return the value of a specific attribute. To avoid
    // this un-necessary allocation, we use a global object which is re-used.
    const RESULT = getEmptyResult()
    function parse(url, options = {}) {
      return factory_parseImpl(
        url,
        5 /* FLAG.ALL */,
        suffix_trie_suffixLookup,
        options,
        getEmptyResult(),
      )
    }
    function getHostname(url, options = {}) {
      /*@__INLINE__*/ factory_resetResult(RESULT)
      return factory_parseImpl(
        url,
        0 /* FLAG.HOSTNAME */,
        suffix_trie_suffixLookup,
        options,
        RESULT,
      ).hostname
    }
    function getPublicSuffix(url, options = {}) {
      /*@__INLINE__*/ resetResult(RESULT)
      return parseImpl(
        url,
        2 /* FLAG.PUBLIC_SUFFIX */,
        suffixLookup,
        options,
        RESULT,
      ).publicSuffix
    }
    function es6_getDomain(url, options = {}) {
      /*@__INLINE__*/ resetResult(RESULT)
      return parseImpl(url, 3 /* FLAG.DOMAIN */, suffixLookup, options, RESULT)
        .domain
    }
    function es6_getSubdomain(url, options = {}) {
      /*@__INLINE__*/ resetResult(RESULT)
      return parseImpl(
        url,
        4 /* FLAG.SUB_DOMAIN */,
        suffixLookup,
        options,
        RESULT,
      ).subdomain
    }
    function es6_getDomainWithoutSuffix(url, options = {}) {
      /*@__INLINE__*/ resetResult(RESULT)
      return parseImpl(url, 5 /* FLAG.ALL */, suffixLookup, options, RESULT)
        .domainWithoutSuffix
    } // CONCATENATED MODULE: ../../libs/common/src/platform/misc/utils.ts
    /* provided dependency */ var utils_process = __webpack_require__(71624)
    /* eslint-disable no-useless-escape */

    const nodeURL =
      typeof window === "undefined" ? __webpack_require__(69573) : null
    class Utils {
      static init() {
        if (Utils.inited) {
          return
        }
        Utils.inited = true
        Utils.isNode =
          typeof utils_process !== "undefined" &&
          utils_process.release != null &&
          utils_process.release.name === "node"
        Utils.isBrowser = typeof window !== "undefined"
        Utils.isMobileBrowser = Utils.isBrowser && this.isMobile(window)
        Utils.isAppleMobileBrowser =
          Utils.isBrowser && this.isAppleMobile(window)
        if (Utils.isNode) {
          Utils.global = __webpack_require__.g
        } else if (Utils.isBrowser) {
          Utils.global = window
        } else {
          // If it's not browser or node then it must be a service worker
          Utils.global = self
        }
      }
      static fromB64ToArray(str) {
        if (str == null) {
          return null
        }
        if (Utils.isNode) {
          return new Uint8Array(Buffer.from(str, "base64"))
        } else {
          const binaryString = Utils.global.atob(str)
          const bytes = new Uint8Array(binaryString.length)
          for (let i = 0; i < binaryString.length; i++) {
            bytes[i] = binaryString.charCodeAt(i)
          }
          return bytes
        }
      }
      static fromUrlB64ToArray(str) {
        return Utils.fromB64ToArray(Utils.fromUrlB64ToB64(str))
      }
      static fromHexToArray(str) {
        if (Utils.isNode) {
          return new Uint8Array(Buffer.from(str, "hex"))
        } else {
          const bytes = new Uint8Array(str.length / 2)
          for (let i = 0; i < str.length; i += 2) {
            bytes[i / 2] = parseInt(str.substr(i, 2), 16)
          }
          return bytes
        }
      }
      static fromUtf8ToArray(str) {
        if (Utils.isNode) {
          return new Uint8Array(Buffer.from(str, "utf8"))
        } else {
          const strUtf8 = unescape(encodeURIComponent(str))
          const arr = new Uint8Array(strUtf8.length)
          for (let i = 0; i < strUtf8.length; i++) {
            arr[i] = strUtf8.charCodeAt(i)
          }
          return arr
        }
      }
      static fromByteStringToArray(str) {
        if (str == null) {
          return null
        }
        const arr = new Uint8Array(str.length)
        for (let i = 0; i < str.length; i++) {
          arr[i] = str.charCodeAt(i)
        }
        return arr
      }
      static fromBufferToB64(buffer) {
        if (buffer == null) {
          return null
        }
        if (Utils.isNode) {
          return Buffer.from(buffer).toString("base64")
        } else {
          let binary = ""
          const bytes = new Uint8Array(buffer)
          for (let i = 0; i < bytes.byteLength; i++) {
            binary += String.fromCharCode(bytes[i])
          }
          return Utils.global.btoa(binary)
        }
      }
      static fromBufferToUrlB64(buffer) {
        return Utils.fromB64toUrlB64(Utils.fromBufferToB64(buffer))
      }
      static fromB64toUrlB64(b64Str) {
        return b64Str.replace(/\+/g, "-").replace(/\//g, "_").replace(/=/g, "")
      }
      static fromBufferToUtf8(buffer) {
        if (Utils.isNode) {
          return Buffer.from(buffer).toString("utf8")
        } else {
          const bytes = new Uint8Array(buffer)
          const encodedString = String.fromCharCode.apply(null, bytes)
          return decodeURIComponent(escape(encodedString))
        }
      }
      static fromBufferToByteString(buffer) {
        return String.fromCharCode.apply(null, new Uint8Array(buffer))
      }
      // ref: https://stackoverflow.com/a/40031979/1090359
      static fromBufferToHex(buffer) {
        if (Utils.isNode) {
          return Buffer.from(buffer).toString("hex")
        } else {
          const bytes = new Uint8Array(buffer)
          return Array.prototype.map
            .call(bytes, (x) => ("00" + x.toString(16)).slice(-2))
            .join("")
        }
      }
      static fromUrlB64ToB64(urlB64Str) {
        let output = urlB64Str.replace(/-/g, "+").replace(/_/g, "/")
        switch (output.length % 4) {
          case 0:
            break
          case 2:
            output += "=="
            break
          case 3:
            output += "="
            break
          default:
            throw new Error("Illegal base64url string!")
        }
        return output
      }
      static fromUrlB64ToUtf8(urlB64Str) {
        return Utils.fromB64ToUtf8(Utils.fromUrlB64ToB64(urlB64Str))
      }
      static fromUtf8ToB64(utfStr) {
        if (Utils.isNode) {
          return Buffer.from(utfStr, "utf8").toString("base64")
        } else {
          return decodeURIComponent(escape(Utils.global.btoa(utfStr)))
        }
      }
      static fromUtf8ToUrlB64(utfStr) {
        return Utils.fromBufferToUrlB64(Utils.fromUtf8ToArray(utfStr))
      }
      static fromB64ToUtf8(b64Str) {
        if (Utils.isNode) {
          return Buffer.from(b64Str, "base64").toString("utf8")
        } else {
          return decodeURIComponent(escape(Utils.global.atob(b64Str)))
        }
      }
      // ref: http://stackoverflow.com/a/2117523/1090359
      static newGuid() {
        return "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx".replace(/[xy]/g, (c) => {
          const r = (Math.random() * 16) | 0
          const v = c === "x" ? r : (r & 0x3) | 0x8
          return v.toString(16)
        })
      }
      static isGuid(id) {
        return RegExp(
          /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/,
          "i",
        ).test(id)
      }
      static getHostname(uriString) {
        if (Utils.isNullOrWhitespace(uriString)) {
          return null
        }
        uriString = uriString.trim()
        if (uriString.startsWith("data:")) {
          return null
        }
        if (uriString.startsWith("about:")) {
          return null
        }
        if (uriString.startsWith("file:")) {
          return null
        }
        // Does uriString contain invalid characters
        // TODO Needs to possibly be extended, although '!' is a reserved character
        if (uriString.indexOf("!") > 0) {
          return null
        }
        try {
          const hostname = getHostname(uriString, {
            validHosts: this.validHosts,
          })
          if (hostname != null) {
            return hostname
          }
        } catch (_a) {
          return null
        }
        return null
      }
      static getHost(uriString) {
        const url = Utils.getUrl(uriString)
        try {
          return url != null && url.host !== "" ? url.host : null
        } catch (_a) {
          return null
        }
      }
      static getDomain(uriString) {
        if (Utils.isNullOrWhitespace(uriString)) {
          return null
        }
        uriString = uriString.trim()
        if (uriString.startsWith("data:")) {
          return null
        }
        if (uriString.startsWith("about:")) {
          return null
        }
        try {
          const parseResult = parse(uriString, { validHosts: this.validHosts })
          if (parseResult != null && parseResult.hostname != null) {
            if (parseResult.hostname === "localhost" || parseResult.isIp) {
              return parseResult.hostname
            }
            if (parseResult.domain != null) {
              return parseResult.domain
            }
            return null
          }
        } catch (_a) {
          return null
        }
        return null
      }
      static getQueryParams(uriString) {
        const url = Utils.getUrl(uriString)
        if (url == null || url.search == null || url.search === "") {
          return null
        }
        const map = new Map()
        const pairs = (
          url.search[0] === "?" ? url.search.substr(1) : url.search
        ).split("&")
        pairs.forEach((pair) => {
          const parts = pair.split("=")
          if (parts.length < 1) {
            return
          }
          map.set(
            decodeURIComponent(parts[0]).toLowerCase(),
            parts[1] == null ? "" : decodeURIComponent(parts[1]),
          )
        })
        return map
      }
      static getSortFunction(i18nService, prop) {
        return (a, b) => {
          if (a[prop] == null && b[prop] != null) {
            return -1
          }
          if (a[prop] != null && b[prop] == null) {
            return 1
          }
          if (a[prop] == null && b[prop] == null) {
            return 0
          }
          // The `as unknown as string` here is unfortunate because typescript doesn't property understand that the return of T[prop] will be a string
          return i18nService.collator
            ? i18nService.collator.compare(a[prop], b[prop])
            : a[prop].localeCompare(b[prop])
        }
      }
      static isNullOrWhitespace(str) {
        return str == null || typeof str !== "string" || str.trim() === ""
      }
      static isNullOrEmpty(str) {
        return str == null || typeof str !== "string" || str == ""
      }
      static isPromise(obj) {
        return (
          obj != undefined &&
          typeof obj["then"] === "function" &&
          typeof obj["catch"] === "function"
        )
      }
      static nameOf(name) {
        return name
      }
      static assign(target, source) {
        return Object.assign(target, source)
      }
      static iterateEnum(obj) {
        return Object.keys(obj)
          .filter((k) => Number.isNaN(+k))
          .map((k) => obj[k])
      }
      static getUrl(uriString) {
        if (this.isNullOrWhitespace(uriString)) {
          return null
        }
        uriString = uriString.trim()
        return Utils.getUrlObject(uriString)
      }
      static camelToPascalCase(s) {
        return s.charAt(0).toUpperCase() + s.slice(1)
      }
      /**
       * There are a few ways to calculate text color for contrast, this one seems to fit accessibility guidelines best.
       * https://stackoverflow.com/a/3943023/6869691
       *
       * @param {string} bgColor
       * @param {number} [threshold] see stackoverflow link above
       * @param {boolean} [svgTextFill]
       * Indicates if this method is performed on an SVG <text> 'fill' attribute (e.g. <text fill="black"></text>).
       * This check is necessary because the '!important' tag cannot be used in a 'fill' attribute.
       */
      static pickTextColorBasedOnBgColor(
        bgColor,
        threshold = 186,
        svgTextFill = false,
      ) {
        const bgColorHexNums =
          bgColor.charAt(0) === "#" ? bgColor.substring(1, 7) : bgColor
        const r = parseInt(bgColorHexNums.substring(0, 2), 16) // hexToR
        const g = parseInt(bgColorHexNums.substring(2, 4), 16) // hexToG
        const b = parseInt(bgColorHexNums.substring(4, 6), 16) // hexToB
        const blackColor = svgTextFill ? "black" : "black !important"
        const whiteColor = svgTextFill ? "white" : "white !important"
        return r * 0.299 + g * 0.587 + b * 0.114 > threshold
          ? blackColor
          : whiteColor
      }
      static stringToColor(str) {
        let hash = 0
        for (let i = 0; i < str.length; i++) {
          hash = str.charCodeAt(i) + ((hash << 5) - hash)
        }
        let color = "#"
        for (let i = 0; i < 3; i++) {
          const value = (hash >> (i * 8)) & 0xff
          color += ("00" + value.toString(16)).substr(-2)
        }
        return color
      }
      /**
       * @throws Will throw an error if the ContainerService has not been attached to the window object
       */
      static getContainerService() {
        if (this.global.bitwardenContainerService == null) {
          throw new Error("global bitwardenContainerService not initialized.")
        }
        return this.global.bitwardenContainerService
      }
      static validateHexColor(color) {
        return /^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$/.test(color)
      }
      /**
       * Converts map to a Record<string, V> with the same data. Inverse of recordToMap
       * Useful in toJSON methods, since Maps are not serializable
       * @param map
       * @returns
       */
      static mapToRecord(map) {
        if (map == null) {
          return null
        }
        if (!(map instanceof Map)) {
          return map
        }
        return Object.fromEntries(map)
      }
      /**
       * Converts record to a Map<string, V> with the same data. Inverse of mapToRecord
       * Useful in fromJSON methods, since Maps are not serializable
       *
       * Warning: If the record has string keys that are numbers, they will be converted to numbers in the map
       * @param record
       * @returns
       */
      static recordToMap(record) {
        if (record == null) {
          return null
        } else if (record instanceof Map) {
          return record
        }
        const entries = Object.entries(record)
        if (entries.length === 0) {
          return new Map()
        }
        if (isNaN(Number(entries[0][0]))) {
          return new Map(entries)
        } else {
          return new Map(entries.map((e) => [Number(e[0]), e[1]]))
        }
      }
      /** Applies Object.assign, but converts the type nicely using Type-Fest Merge<Destination, Source> */
      static merge(destination, source) {
        return Object.assign(destination, source)
      }
      /**
       * encodeURIComponent escapes all characters except the following:
       * alphabetic, decimal digits, - _ . ! ~ * ' ( )
       * https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/encodeURIComponent#encoding_for_rfc3986
       */
      static encodeRFC3986URIComponent(str) {
        return encodeURIComponent(str).replace(
          /[!'()*]/g,
          (c) => `%${c.charCodeAt(0).toString(16).toUpperCase()}`,
        )
      }
      /**
       * Normalizes a path for defense against attacks like traversals
       * @param denormalizedPath
       * @returns
       */
      static normalizePath(denormalizedPath) {
        return path_browserify
          .normalize(decodeURIComponent(denormalizedPath))
          .replace(/^(\.\.(\/|\\|$))+/, "")
      }
      static isMobile(win) {
        let mobile = false
        ;((a) => {
          if (
            /(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|mobile.+firefox|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows ce|xda|xiino/i.test(
              a,
            ) ||
            /1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-/i.test(
              a.substr(0, 4),
            )
          ) {
            mobile = true
          }
        })(win.navigator.userAgent || win.navigator.vendor || win.opera)
        return mobile || win.navigator.userAgent.match(/iPad/i) != null
      }
      static delay(ms) {
        return new Promise((resolve) => setTimeout(resolve, ms))
      }
      /**
       * Generate an observable from a function that returns a promise.
       * Similar to the rxjs function {@link from} with one big exception:
       * {@link from} will not re-execute the function when observers resubscribe.
       * {@link Util.asyncToObservable} will execute `generator` for every
       * subscribe, making it ideal if the value ever needs to be refreshed.
       * */
      static asyncToObservable(generator) {
        return of(undefined).pipe(switchMap(() => generator()))
      }
      /**
       * Return the number of days remaining before a target date arrives.
       * Returns 0 if the day has already passed.
       */
      static daysRemaining(targetDate) {
        const diffTime = targetDate.getTime() - Date.now()
        const msPerDay = 86400000
        return Math.max(0, Math.floor(diffTime / msPerDay))
      }
      static isAppleMobile(win) {
        return (
          win.navigator.userAgent.match(/iPhone/i) != null ||
          win.navigator.userAgent.match(/iPad/i) != null
        )
      }
      static getUrlObject(uriString) {
        // All the methods below require a protocol to properly parse a URL string
        // Assume http if no other protocol is present
        const hasProtocol = uriString.indexOf("://") > -1
        if (!hasProtocol && uriString.indexOf(".") > -1) {
          uriString = "http://" + uriString
        } else if (!hasProtocol) {
          return null
        }
        try {
          if (nodeURL != null) {
            return new nodeURL.URL(uriString)
          }
          return new URL(uriString)
        } catch (e) {
          // Ignore error
        }
        return null
      }
    }
    Utils.inited = false
    Utils.isNode = false
    Utils.isBrowser = true
    Utils.isMobileBrowser = false
    Utils.isAppleMobileBrowser = false
    Utils.global = null
    // Transpiled version of /\p{Emoji_Presentation}/gu using https://mothereff.in/regexpu. Used for compatability in older browsers.
    Utils.regexpEmojiPresentation =
      /(?:[\u231A\u231B\u23E9-\u23EC\u23F0\u23F3\u25FD\u25FE\u2614\u2615\u2648-\u2653\u267F\u2693\u26A1\u26AA\u26AB\u26BD\u26BE\u26C4\u26C5\u26CE\u26D4\u26EA\u26F2\u26F3\u26F5\u26FA\u26FD\u2705\u270A\u270B\u2728\u274C\u274E\u2753-\u2755\u2757\u2795-\u2797\u27B0\u27BF\u2B1B\u2B1C\u2B50\u2B55]|\uD83C[\uDC04\uDCCF\uDD8E\uDD91-\uDD9A\uDDE6-\uDDFF\uDE01\uDE1A\uDE2F\uDE32-\uDE36\uDE38-\uDE3A\uDE50\uDE51\uDF00-\uDF20\uDF2D-\uDF35\uDF37-\uDF7C\uDF7E-\uDF93\uDFA0-\uDFCA\uDFCF-\uDFD3\uDFE0-\uDFF0\uDFF4\uDFF8-\uDFFF]|\uD83D[\uDC00-\uDC3E\uDC40\uDC42-\uDCFC\uDCFF-\uDD3D\uDD4B-\uDD4E\uDD50-\uDD67\uDD7A\uDD95\uDD96\uDDA4\uDDFB-\uDE4F\uDE80-\uDEC5\uDECC\uDED0-\uDED2\uDED5-\uDED7\uDEEB\uDEEC\uDEF4-\uDEFC\uDFE0-\uDFEB]|\uD83E[\uDD0C-\uDD3A\uDD3C-\uDD45\uDD47-\uDD78\uDD7A-\uDDCB\uDDCD-\uDDFF\uDE70-\uDE74\uDE78-\uDE7A\uDE80-\uDE86\uDE90-\uDEA8\uDEB0-\uDEB6\uDEC0-\uDEC2\uDED0-\uDED6])/g
    Utils.validHosts = ["localhost"]
    Utils.originalMinimumPasswordLength = 8
    Utils.minimumPasswordLength = 12
    Utils.DomainMatchBlacklist = new Map([
      ["google.com", new Set(["script.google.com"])],
    ])
    Utils.init() // CONCATENATED MODULE: ../../libs/common/src/vault/services/fido2/fido2-utils.ts

    class Fido2Utils {
      static bufferToString(bufferSource) {
        const buffer = Fido2Utils.bufferSourceToUint8Array(bufferSource)
        return Utils.fromBufferToUrlB64(buffer)
      }
      static stringToBuffer(str) {
        return Utils.fromUrlB64ToArray(str)
      }
      static bufferSourceToUint8Array(bufferSource) {
        if (Fido2Utils.isArrayBuffer(bufferSource)) {
          return new Uint8Array(bufferSource)
        } else {
          return new Uint8Array(bufferSource.buffer)
        }
      }
      /** Utility function to identify type of bufferSource. Necessary because of differences between runtimes */
      static isArrayBuffer(bufferSource) {
        return (
          bufferSource instanceof ArrayBuffer ||
          bufferSource.buffer === undefined
        )
      }
    } // CONCATENATED MODULE: ./src/vault/fido2/webauthn-utils.ts

    class WebauthnUtils {
      static mapCredentialCreationOptions(
        options,
        origin,
        sameOriginWithAncestors,
        fallbackSupported,
      ) {
        var _a, _b, _c, _d
        const keyOptions = options.publicKey
        if (keyOptions == undefined) {
          throw new Error("Public-key options not found")
        }
        return {
          origin,
          attestation: keyOptions.attestation,
          authenticatorSelection: {
            requireResidentKey:
              (_a = keyOptions.authenticatorSelection) === null || _a === void 0
                ? void 0
                : _a.requireResidentKey,
            residentKey:
              (_b = keyOptions.authenticatorSelection) === null || _b === void 0
                ? void 0
                : _b.residentKey,
            userVerification:
              (_c = keyOptions.authenticatorSelection) === null || _c === void 0
                ? void 0
                : _c.userVerification,
          },
          challenge: Fido2Utils.bufferToString(keyOptions.challenge),
          excludeCredentials:
            (_d = keyOptions.excludeCredentials) === null || _d === void 0
              ? void 0
              : _d.map((credential) => ({
                  id: Fido2Utils.bufferToString(credential.id),
                  transports: credential.transports,
                  type: credential.type,
                })),
          extensions: undefined,
          pubKeyCredParams: keyOptions.pubKeyCredParams.map((params) => ({
            alg: params.alg,
            type: params.type,
          })),
          rp: {
            id: keyOptions.rp.id,
            name: keyOptions.rp.name,
          },
          user: {
            id: Fido2Utils.bufferToString(keyOptions.user.id),
            displayName: keyOptions.user.displayName,
          },
          timeout: keyOptions.timeout,
          sameOriginWithAncestors,
          fallbackSupported,
        }
      }
      static mapCredentialRegistrationResult(result) {
        const credential = {
          id: result.credentialId,
          rawId: Fido2Utils.stringToBuffer(result.credentialId),
          type: "public-key",
          authenticatorAttachment: "cross-platform",
          response: {
            clientDataJSON: Fido2Utils.stringToBuffer(result.clientDataJSON),
            attestationObject: Fido2Utils.stringToBuffer(
              result.attestationObject,
            ),
            getAuthenticatorData() {
              return Fido2Utils.stringToBuffer(result.authData)
            },
            getPublicKey() {
              return null
            },
            getPublicKeyAlgorithm() {
              return result.publicKeyAlgorithm
            },
            getTransports() {
              return result.transports
            },
          },
          getClientExtensionResults: () => ({}),
        }
        // Modify prototype chains to fix `instanceof` calls.
        // This makes these objects indistinguishable from the native classes.
        // Unfortunately PublicKeyCredential does not have a javascript constructor so `extends` does not work here.
        Object.setPrototypeOf(
          credential.response,
          AuthenticatorAttestationResponse.prototype,
        )
        Object.setPrototypeOf(credential, PublicKeyCredential.prototype)
        return credential
      }
      static mapCredentialRequestOptions(
        options,
        origin,
        sameOriginWithAncestors,
        fallbackSupported,
      ) {
        var _a, _b
        const keyOptions = options.publicKey
        if (keyOptions == undefined) {
          throw new Error("Public-key options not found")
        }
        return {
          origin,
          allowedCredentialIds:
            (_b =
              (_a = keyOptions.allowCredentials) === null || _a === void 0
                ? void 0
                : _a.map((c) => Fido2Utils.bufferToString(c.id))) !== null &&
            _b !== void 0
              ? _b
              : [],
          challenge: Fido2Utils.bufferToString(keyOptions.challenge),
          rpId: keyOptions.rpId,
          userVerification: keyOptions.userVerification,
          timeout: keyOptions.timeout,
          sameOriginWithAncestors,
          fallbackSupported,
        }
      }
      static mapCredentialAssertResult(result) {
        const credential = {
          id: result.credentialId,
          rawId: Fido2Utils.stringToBuffer(result.credentialId),
          type: "public-key",
          response: {
            authenticatorData: Fido2Utils.stringToBuffer(
              result.authenticatorData,
            ),
            clientDataJSON: Fido2Utils.stringToBuffer(result.clientDataJSON),
            signature: Fido2Utils.stringToBuffer(result.signature),
            userHandle: Fido2Utils.stringToBuffer(result.userHandle),
          },
          getClientExtensionResults: () => ({}),
          authenticatorAttachment: "cross-platform",
        }
        // Modify prototype chains to fix `instanceof` calls.
        // This makes these objects indistinguishable from the native classes.
        // Unfortunately PublicKeyCredential does not have a javascript constructor so `extends` does not work here.
        Object.setPrototypeOf(
          credential.response,
          AuthenticatorAssertionResponse.prototype,
        )
        Object.setPrototypeOf(credential, PublicKeyCredential.prototype)
        return credential
      }
    } // CONCATENATED MODULE: ./src/vault/fido2/content/messaging/message.ts

    var MessageType
    ;(function (MessageType) {
      MessageType[(MessageType["CredentialCreationRequest"] = 0)] =
        "CredentialCreationRequest"
      MessageType[(MessageType["CredentialCreationResponse"] = 1)] =
        "CredentialCreationResponse"
      MessageType[(MessageType["CredentialGetRequest"] = 2)] =
        "CredentialGetRequest"
      MessageType[(MessageType["CredentialGetResponse"] = 3)] =
        "CredentialGetResponse"
      MessageType[(MessageType["AbortRequest"] = 4)] = "AbortRequest"
      MessageType[(MessageType["AbortResponse"] = 5)] = "AbortResponse"
      MessageType[(MessageType["ErrorResponse"] = 6)] = "ErrorResponse"
    })(MessageType || (MessageType = {})) // CONCATENATED MODULE: ./src/vault/fido2/content/messaging/messenger.ts

    var messenger_awaiter =
      (undefined && undefined.__awaiter) ||
      function (thisArg, _arguments, P, generator) {
        function adopt(value) {
          return value instanceof P
            ? value
            : new P(function (resolve) {
                resolve(value)
              })
        }
        return new (P || (P = Promise))(function (resolve, reject) {
          function fulfilled(value) {
            try {
              step(generator.next(value))
            } catch (e) {
              reject(e)
            }
          }
          function rejected(value) {
            try {
              step(generator["throw"](value))
            } catch (e) {
              reject(e)
            }
          }
          function step(result) {
            result.done
              ? resolve(result.value)
              : adopt(result.value).then(fulfilled, rejected)
          }
          step((generator = generator.apply(thisArg, _arguments || [])).next())
        })
      }

    const SENDER = "bitwarden-webauthn"
    /**
     * A class that handles communication between the page and content script. It converts
     * the browser's broadcasting API into a request/response API with support for seamlessly
     * handling aborts and exceptions across separate execution contexts.
     */
    class Messenger {
      /**
       * Creates a messenger that uses the browser's `window.postMessage` API to initiate
       * requests in the content script. Every request will then create it's own
       * `MessageChannel` through which all subsequent communication will be sent through.
       *
       * @param window the window object to use for communication
       * @returns a `Messenger` instance
       */
      static forDOMCommunication(window) {
        const windowOrigin = window.location.origin
        return new Messenger({
          postMessage: (message, port) =>
            window.postMessage(message, windowOrigin, [port]),
          addEventListener: (listener) =>
            window.addEventListener("message", (event) => {
              if (event.origin !== windowOrigin) {
                return
              }
              listener(event)
            }),
        })
      }
      constructor(broadcastChannel) {
        this.broadcastChannel = broadcastChannel
        this.broadcastChannel.addEventListener((event) =>
          messenger_awaiter(this, void 0, void 0, function* () {
            var _a
            if (this.handler === undefined) {
              return
            }
            const message = event.data
            const port =
              (_a = event.ports) === null || _a === void 0 ? void 0 : _a[0]
            if (
              (message === null || message === void 0
                ? void 0
                : message.SENDER) !== SENDER ||
              message == null ||
              port == null
            ) {
              return
            }
            const abortController = new AbortController()
            port.onmessage = (event) => {
              if (event.data.type === MessageType.AbortRequest) {
                abortController.abort()
              }
            }
            try {
              const handlerResponse = yield this.handler(
                message,
                abortController,
              )
              port.postMessage(
                Object.assign(Object.assign({}, handlerResponse), { SENDER }),
              )
            } catch (error) {
              port.postMessage({
                SENDER,
                type: MessageType.ErrorResponse,
                error: JSON.stringify(error, Object.getOwnPropertyNames(error)),
              })
            } finally {
              port.close()
            }
          }),
        )
      }
      /**
       * Sends a request to the content script and returns the response.
       * AbortController signals will be forwarded to the content script.
       *
       * @param request data to send to the content script
       * @param abortController the abort controller that might be used to abort the request
       * @returns the response from the content script
       */
      request(request, abortController) {
        return messenger_awaiter(this, void 0, void 0, function* () {
          const requestChannel = new MessageChannel()
          const { port1: localPort, port2: remotePort } = requestChannel
          try {
            const promise = new Promise((resolve) => {
              localPort.onmessage = (event) => resolve(event.data)
            })
            const abortListener = () =>
              localPort.postMessage({
                metadata: { SENDER },
                type: MessageType.AbortRequest,
              })
            abortController === null || abortController === void 0
              ? void 0
              : abortController.signal.addEventListener("abort", abortListener)
            this.broadcastChannel.postMessage(
              Object.assign(Object.assign({}, request), { SENDER }),
              remotePort,
            )
            const response = yield promise
            abortController === null || abortController === void 0
              ? void 0
              : abortController.signal.removeEventListener(
                  "abort",
                  abortListener,
                )
            if (response.type === MessageType.ErrorResponse) {
              const error = new Error()
              Object.assign(error, JSON.parse(response.error))
              throw error
            }
            return response
          } finally {
            localPort.close()
          }
        })
      }
    } // CONCATENATED MODULE: ./src/vault/fido2/content/page-script.ts

    var page_script_awaiter =
      (undefined && undefined.__awaiter) ||
      function (thisArg, _arguments, P, generator) {
        function adopt(value) {
          return value instanceof P
            ? value
            : new P(function (resolve) {
                resolve(value)
              })
        }
        return new (P || (P = Promise))(function (resolve, reject) {
          function fulfilled(value) {
            try {
              step(generator.next(value))
            } catch (e) {
              reject(e)
            }
          }
          function rejected(value) {
            try {
              step(generator["throw"](value))
            } catch (e) {
              reject(e)
            }
          }
          function step(result) {
            result.done
              ? resolve(result.value)
              : adopt(result.value).then(fulfilled, rejected)
          }
          step((generator = generator.apply(thisArg, _arguments || [])).next())
        })
      }

    const BrowserPublicKeyCredential = window.PublicKeyCredential
    const browserNativeWebauthnSupport = window.PublicKeyCredential != undefined
    let browserNativeWebauthnPlatformAuthenticatorSupport = false
    if (!browserNativeWebauthnSupport) {
      // Polyfill webauthn support
      try {
        // credentials is read-only if supported, use type-casting to force assignment
        navigator.credentials = {
          create() {
            return page_script_awaiter(this, void 0, void 0, function* () {
              throw new Error("Webauthn not supported in this browser.")
            })
          },
          get() {
            return page_script_awaiter(this, void 0, void 0, function* () {
              throw new Error("Webauthn not supported in this browser.")
            })
          },
        }
        window.PublicKeyCredential = class PolyfillPublicKeyCredential {
          static isUserVerifyingPlatformAuthenticatorAvailable() {
            return Promise.resolve(true)
          }
        }
        window.AuthenticatorAttestationResponse = class PolyfillAuthenticatorAttestationResponse {}
      } catch (_a) {
        /* empty */
      }
    }
    if (browserNativeWebauthnSupport) {
      BrowserPublicKeyCredential.isUserVerifyingPlatformAuthenticatorAvailable().then(
        (available) => {
          browserNativeWebauthnPlatformAuthenticatorSupport = available
          if (!available) {
            // Polyfill platform authenticator support
            window.PublicKeyCredential.isUserVerifyingPlatformAuthenticatorAvailable =
              () => Promise.resolve(true)
          }
        },
      )
    }
    const browserCredentials = {
      create: navigator.credentials.create.bind(navigator.credentials),
      get: navigator.credentials.get.bind(navigator.credentials),
    }
    const messenger = Messenger.forDOMCommunication(window)
    function isSameOriginWithAncestors() {
      try {
        return window.self === window.top
      } catch (_a) {
        return false
      }
    }
    navigator.credentials.create = (options, abortController) =>
      page_script_awaiter(void 0, void 0, void 0, function* () {
        var _b, _c
        if (!isWebauthnCall(options)) {
          return yield browserCredentials.create(options)
        }
        const fallbackSupported =
          (((_b =
            options === null || options === void 0
              ? void 0
              : options.publicKey) === null || _b === void 0
            ? void 0
            : _b.authenticatorSelection.authenticatorAttachment) ===
            "platform" &&
            browserNativeWebauthnPlatformAuthenticatorSupport) ||
          (((_c =
            options === null || options === void 0
              ? void 0
              : options.publicKey) === null || _c === void 0
            ? void 0
            : _c.authenticatorSelection.authenticatorAttachment) !==
            "platform" &&
            browserNativeWebauthnSupport)
        try {
          const isNotIframe = isSameOriginWithAncestors()
          const response = yield messenger.request(
            {
              type: MessageType.CredentialCreationRequest,
              data: WebauthnUtils.mapCredentialCreationOptions(
                options,
                window.location.origin,
                isNotIframe,
                fallbackSupported,
              ),
            },
            abortController,
          )
          if (response.type !== MessageType.CredentialCreationResponse) {
            throw new Error("Something went wrong.")
          }
          return WebauthnUtils.mapCredentialRegistrationResult(response.result)
        } catch (error) {
          if (error && error.fallbackRequested && fallbackSupported) {
            yield waitForFocus()
            return yield browserCredentials.create(options)
          }
          throw error
        }
      })
    navigator.credentials.get = (options, abortController) =>
      page_script_awaiter(void 0, void 0, void 0, function* () {
        if (!isWebauthnCall(options)) {
          return yield browserCredentials.get(options)
        }
        const fallbackSupported = browserNativeWebauthnSupport
        try {
          if (
            (options === null || options === void 0
              ? void 0
              : options.mediation) &&
            options.mediation !== "optional"
          ) {
            throw new FallbackRequestedError()
          }
          const response = yield messenger.request(
            {
              type: MessageType.CredentialGetRequest,
              data: WebauthnUtils.mapCredentialRequestOptions(
                options,
                window.location.origin,
                true,
                fallbackSupported,
              ),
            },
            abortController,
          )
          if (response.type !== MessageType.CredentialGetResponse) {
            throw new Error("Something went wrong.")
          }
          return WebauthnUtils.mapCredentialAssertResult(response.result)
        } catch (error) {
          if (error && error.fallbackRequested && fallbackSupported) {
            yield waitForFocus()
            return yield browserCredentials.get(options)
          }
          throw error
        }
      })
    function isWebauthnCall(options) {
      return options && "publicKey" in options
    }
    /**
     * Wait for window to be focused.
     * Safari doesn't allow scripts to trigger webauthn when window is not focused.
     *
     * @param fallbackWait How long to wait when the script is not able to add event listeners to `window.top`. Defaults to 500ms.
     * @param timeout Maximum time to wait for focus in milliseconds. Defaults to 5 minutes.
     * @returns Promise that resolves when window is focused, or rejects if timeout is reached.
     */
    function waitForFocus(fallbackWait = 500, timeout = 5 * 60 * 1000) {
      return page_script_awaiter(this, void 0, void 0, function* () {
        try {
          if (window.top.document.hasFocus()) {
            return
          }
        } catch (_a) {
          // Cannot access window.top due to cross-origin frame, fallback to waiting
          return yield new Promise((resolve) =>
            window.setTimeout(resolve, fallbackWait),
          )
        }
        let focusListener
        const focusPromise = new Promise((resolve) => {
          focusListener = () => resolve()
          window.top.addEventListener("focus", focusListener)
        })
        let timeoutId
        const timeoutPromise = new Promise((_, reject) => {
          timeoutId = window.setTimeout(
            () =>
              reject(
                new DOMException(
                  "The operation either timed out or was not allowed.",
                  "AbortError",
                ),
              ),
            timeout,
          )
        })
        try {
          yield Promise.race([focusPromise, timeoutPromise])
        } finally {
          window.top.removeEventListener("focus", focusListener)
          window.clearTimeout(timeoutId)
        }
      })
    }
  })()

  /******/
})()
