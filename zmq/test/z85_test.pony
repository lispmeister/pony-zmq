
use "ponytest"
use "../z85"

class Z85Test is UnitTest
  new iso create() => None
  fun name(): String => "zmq.Z85"
  
  fun apply(h: TestHelper): TestResult =>
    // Example from ZMQ RFC 32 for Z85.
    test_pair(h, "HelloWorld", recover [as U8:
      0x86, 0x4F, 0xD2, 0x6F, 0xB5, 0x59, 0xF7, 0x5B
    ] end)
    
    // Examples of encoded string size not divisible by 5
    test_decode_error(h, "HelloWorlds")
    test_decode_error(h, "HelloWorl")
    
    // Examples of illegal characters in encoded string
    test_decode_error(h, "Hello Z85!")
    test_decode_error(h, "Hello\nZ85!")
    test_decode_error(h, "Hello\x7FZ85!")
    
    // Examples of binary size not divisible by 4
    test_encode_error(h, recover [as U8:
      0x86, 0x4F, 0xD2, 0x6F, 0xB5, 0x59, 0xF7, 0x5B, 0x01
    ] end)
    test_encode_error(h, recover [as U8:
      0x86, 0x4F, 0xD2, 0x6F, 0xB5, 0x59, 0xF7
    ] end)
    
    // Example client public key from `man curve_zmq`.
    test_pair(h, "Yne@$w-vo<fVvi]a<NY6T1ed:M$fCG*[IaLV{hID", recover [as U8:
      0xBB, 0x88, 0x47, 0x1D, 0x65, 0xE2, 0x65, 0x9B,
      0x30, 0xC5, 0x5A, 0x53, 0x21, 0xCE, 0xBB, 0x5A,
      0xAB, 0x2B, 0x70, 0xA3, 0x98, 0x64, 0x5C, 0x26,
      0xDC, 0xA2, 0xB2, 0xFC, 0xB4, 0x3F, 0xC5, 0x18
    ] end)
    
    // Example client private key from `man curve_zmq`.
    test_pair(h, "D:)Q[IlAW!ahhC2ac:9*A}h:p?([4%wOTJ%JR%cs", recover [as U8:
      0x7B, 0xB8, 0x64, 0xB4, 0x89, 0xAF, 0xA3, 0x67,
      0x1F, 0xBE, 0x69, 0x10, 0x1F, 0x94, 0xB3, 0x89,
      0x72, 0xF2, 0x48, 0x16, 0xDF, 0xB0, 0x1B, 0x51,
      0x65, 0x6B, 0x3F, 0xEC, 0x8D, 0xFD, 0x08, 0x88
    ] end)
    
    // Example server public key from `man curve_zmq`.
    test_pair(h, "rq:rM>}U?@Lns47E1%kR.o@n%FcmmsL/@{H8]yf7", recover [as U8:
      0x54, 0xFC, 0xBA, 0x24, 0xE9, 0x32, 0x49, 0x96,
      0x93, 0x16, 0xFB, 0x61, 0x7C, 0x87, 0x2B, 0xB0,
      0xC1, 0xD1, 0xFF, 0x14, 0x80, 0x04, 0x27, 0xC5,
      0x94, 0xCB, 0xFA, 0xCF, 0x1B, 0xC2, 0xD6, 0x52
    ] end)
    
    // Example server private key from `man curve_zmq`.
    test_pair(h, "JTKVSB%%)wK0E.X)V>+}o?pNmC{O&4W4b!Ni{Lh6", recover [as U8:
      0x8E, 0x0B, 0xDD, 0x69, 0x76, 0x28, 0xB9, 0x1D,
      0x8F, 0x24, 0x55, 0x87, 0xEE, 0x95, 0xC5, 0xB0,
      0x4D, 0x48, 0x96, 0x3F, 0x79, 0x25, 0x98, 0x77,
      0xB4, 0x9C, 0xD9, 0x06, 0x3A, 0xEA, 0xD3, 0xB7
    ] end)
  
  fun test_pair(h: TestHelper, str: String, bin: Array[U8] val): TestResult =>
    try h.expect_eq[String](Z85.encode(bin), str)
    else h.assert_failed("expected to be able to Z85-encode to string: "+str)
    end
    try h.expect_eq[String](Z85.decode(str), recover String.append(bin) end)
    else h.assert_failed("expected to be able to Z85-decode from string: "+str)
    end
    true
  
  fun test_decode_error(h: TestHelper, str: String): TestResult =>
    try Z85.decode(str)
      h.assert_failed("expected NOT to be able to Z85-decode from string: "+str)
    end
    true
  
  fun test_encode_error(h: TestHelper, bin: Array[U8] val): TestResult =>
    try Z85.encode(bin)
      h.assert_failed("expected NOT to be able to Z85-encode the binary.")
    end
    true
