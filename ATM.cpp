#include <iostream>
#include <string>
using namespace std;

enum State
{
  INITIAL,
  LANGUAGE_SELECTION,
  PASSWORD_VERIFICATION,
  BANKING_OPERATION_SELECTION,
  DEPOSIT_OPERATION,
  WITHDRAW_OPERATION,
  BALANCE_OPERATION,
  ANOTHER_SERVICE
};

bool card_inserted = false;
string selected_language;
string user_password;
string selected_operation;
int deposit_amount = 0;
int withdraw_amount = 0;
int account_balance = 0;

void cardInsertion()
{
  card_inserted = true;
}

string Language()
{
  cout << "Choose language (EN/AR): ";
  cin >> selected_language;
  return selected_language;
}

bool passwordVerification(const string &password)
{
  return (password == "2711");
}

string Password()
{
  cout << "Enter password: ";
  cin >> user_password;
  return user_password;
}

string bankingOperation()
{
  cout << "Choose operation (DEPOSIT/WITHDRAW/BALANCE): ";
  cin >> selected_operation;
  return selected_operation;
}

void depositOperation()
{
  cout << "Enter the amount you want to deposit: ";
  cin >> deposit_amount;

  if (deposit_amount > 500)
  {
    cerr << "Error: Cannot deposit more than 500 in one time. Try a smaller amount." << endl;
  }
  else
  {
    account_balance += deposit_amount;
    cout << "Deposit successful. Thank you!" << endl;
  }
}

void withdrawOperation()
{
  cout << "Enter the amount you want to withdraw: ";
  cin >> withdraw_amount;

  if (withdraw_amount > 500 || withdraw_amount > account_balance)
  {
    cerr << "Error: Cannot withdraw more than 500 in one time or more than your account balance. Try a smaller amount." << endl;
  }
  else
  {
    account_balance -= withdraw_amount;
    cout << "Please wait for your money to come out." << endl;
  }
}

void balanceOperation()
{
  cout << "Your account balance is: " << account_balance << endl;
}

bool anotherService()
{
  char response;
  cout << "Do you want another service? (Y/N): ";
  cin >> response;
  return (response == 'Y' || response == 'y');
}

int main()
{
  State state = INITIAL;
  bool exitRequested = false;

  while (!exitRequested)
  {
    switch (state)
    {
    case INITIAL:
      cardInsertion();
      if (card_inserted)
      {
        state = LANGUAGE_SELECTION;
      }
      break;

    case LANGUAGE_SELECTION:
      selected_language = Language();
      state = PASSWORD_VERIFICATION;
      break;

    case PASSWORD_VERIFICATION:
      user_password = Password();
      if (passwordVerification(user_password))
      {
        state = BANKING_OPERATION_SELECTION;
      }
      else
      {
        cout << "Invalid password. Try again." << endl;
        state = LANGUAGE_SELECTION;
      }
      break;

    case BANKING_OPERATION_SELECTION:
      selected_operation = bankingOperation();
      if (selected_operation == "DEPOSIT")
      {
        state = DEPOSIT_OPERATION;
      }
      else if (selected_operation == "WITHDRAW")
      {
        state = WITHDRAW_OPERATION;
      }
      else if (selected_operation == "BALANCE")
      {
        state = BALANCE_OPERATION;
      }
      break;

    case DEPOSIT_OPERATION:
      depositOperation();
      state = ANOTHER_SERVICE;
      break;

    case WITHDRAW_OPERATION:
      withdrawOperation();
      state = ANOTHER_SERVICE;
      break;

    case BALANCE_OPERATION:
      balanceOperation();
      state = ANOTHER_SERVICE;
      break;

    case ANOTHER_SERVICE:
      if (anotherService())
      {
        state = BANKING_OPERATION_SELECTION;
      }
      else
      {
        cout << "Goodbye!" << endl;
        state = INITIAL;
        exitRequested = true;
      }
      break;
    }
  }

  return 0;
}
