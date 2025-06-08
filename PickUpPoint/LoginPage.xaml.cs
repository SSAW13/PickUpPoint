using System.Data;
using System.Security.Cryptography;
using System.Text;

namespace PickUpPoint;

public partial class LoginPage : ContentPage
{
    private DatabaseConnection _databaseConnection = new DatabaseConnection();
	public LoginPage()
	{
		InitializeComponent();
	}

    private async void LoginClicked(object sender, EventArgs e)
    {
        string login = UsernameEntry.Text;
        string password = passcrypt(PasswordEntry.Text);

        UsernameEntry.Text = "";
        PasswordEntry.Text = "";

        string query = "SELECT lastname, name, role, login FROM users WHERE login = \'" + login + "\' AND password = \'" + password + "\';";

        DataTable dataTable = _databaseConnection.ExecuteQuery(query);

        try
        { 
            SecureStorage.Default.RemoveAll();
            await SecureStorage.Default.SetAsync("lastname", dataTable.Rows[0][0].ToString());
            await SecureStorage.Default.SetAsync("name", dataTable.Rows[0][1].ToString());
            await SecureStorage.Default.SetAsync("role", dataTable.Rows[0][2].ToString());
            await SecureStorage.Default.SetAsync("login", dataTable.Rows[0][3].ToString());
            await Navigation.PushAsync(new MainPage());

        }
        catch (Exception)
        {
            await DisplayAlert("Ошибка", "Введены некорректные данные для входа в систему", "OK");

        }
    }

    private static string passcrypt(string input)
    {
        if (string.IsNullOrEmpty(input))
        {
            return string.Empty;
        }

        using (SHA256 sha256 = SHA256.Create()) {
            byte[] inputBytes = Encoding.UTF8.GetBytes(input);
            byte[] hashBytes = sha256.ComputeHash(inputBytes);
            StringBuilder sb = new StringBuilder();
            foreach (byte b in hashBytes)
            {
                sb.Append(b.ToString("x2"));
            }
            return sb.ToString();
        }
    }
}