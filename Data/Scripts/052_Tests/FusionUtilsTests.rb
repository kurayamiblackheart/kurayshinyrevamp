def test_is_fusion_of_any
  test_list = LEGENDARIES_LIST
  echoln _INTL("test list: {1}")

  call_is_fusion_of_any_test(:MEWTWO, LEGENDARIES_LIST, true)
  call_is_fusion_of_any_test(:PIKACHU, LEGENDARIES_LIST, false)

  call_is_fusion_of_any_test(:B150H40, LEGENDARIES_LIST, true)
  call_is_fusion_of_any_test(:B40H150, LEGENDARIES_LIST, true)
  call_is_fusion_of_any_test(:B151H150, LEGENDARIES_LIST, true)
  call_is_fusion_of_any_test(:B25H26, LEGENDARIES_LIST, false)

end

def call_is_fusion_of_any_test(pokemon, list, expected_result)
  result = is_fusion_of_any(pokemon, LEGENDARIES_LIST)
  verdict = result == expected_result ? "OK" : "TEST FAILED"
  echoln _INTL("{1} -> expected: {2}, result: {3}\t{4}", pokemon, expected_result, result, verdict)

end