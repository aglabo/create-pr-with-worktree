#shellcheck shell=sh

Describe 'greeting.sh'
  Include scripts/greeting.sh

  Describe 'greeting()'
    Context 'with valid input'
      It 'outputs greeting with simple name'
        When call greeting "World"
        The output should eq "Hello, World!!"
        The status should be success
      End

      It 'outputs greeting with name containing spaces'
        When call greeting "John Doe"
        The output should eq "Hello, John Doe!!"
        The status should be success
      End

      It 'outputs greeting with special characters'
        When call greeting "User123"
        The output should eq "Hello, User123!!"
        The status should be success
      End
    End

    Context 'with invalid input'
      It 'returns error when no arguments provided'
        When call greeting
        The error should include "Error:"
        The error should include "Name parameter is required"
        The status should eq 1
      End

      It 'returns error when empty string provided'
        When call greeting ""
        The error should include "Error:"
        The error should include "Name parameter is required"
        The status should eq 1
      End
    End
  End
End
