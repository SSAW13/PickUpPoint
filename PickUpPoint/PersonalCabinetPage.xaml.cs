namespace PickUpPoint;
using Microsoft.Maui.Controls;
using Microsoft.UI.Xaml.Controls.Primitives;
using System.Data;

public partial class PersonalCabinetPage : ContentPage
{
    DatabaseConnection _databaseConnection = new DatabaseConnection();
	public PersonalCabinetPage()
	{
		InitializeComponent();
        FormLoad();
	}

    private async void FormLoad()
    {
        string l1 = await SecureStorage.Default.GetAsync("lastname");
        string l2 = await SecureStorage.Default.GetAsync("name");
        string l3 = await SecureStorage.Default.GetAsync("role");

        lastname.Text += "\n" + l1;
        name.Text += "\n" + l2;
        role.Text += "\n" + l3;
    }

    private async void LogoutClicked(object sender, EventArgs e)
    {
        await Shell.Current.GoToAsync("//LoginPage", true);

        await Shell.Current.Navigation.PopToRootAsync();

        SecureStorage.Default.RemoveAll();
    }

    private async void EditPassword(object sender, EventArgs e)
    {
        if (!string.IsNullOrWhiteSpace(OldPass.Text) && !string.IsNullOrWhiteSpace(NewPass.Text) && !string.IsNullOrWhiteSpace(reNewPass.Text))
        {
            if (OldPass.Text != NewPass.Text)
            {
                if (NewPass.Text == reNewPass.Text)
                {
                    string l4 = await SecureStorage.Default.GetAsync("login");
                    string query = "SELECT newPass(\'" + l4 + "\', \'" + OldPass.Text + "\', \'" + NewPass.Text + "\');";
                    DataTable dataTable = _databaseConnection.ExecuteQuery(query);
                    if (Convert.ToInt32(dataTable.Rows[0][0]) == 0)
                    {
                        await DisplayAlert("Успех", "Пароль успешно сменен", "ОК");
                    } else
                    {
                        await DisplayAlert("Ошибка", "Введен неверный пароль", "ОК");
                    }
                }
                else
                {
                    await DisplayAlert("Ошибка", "Новый пароль и его повторение  не совпадают", "ОК");
                }
            }
            else
            {
                await DisplayAlert("Ошибка", "Новый и старый пароль не должны совпадать", "ОК");
            }
        }
        else
        {
            await DisplayAlert("Ошибка", "Все поля должны быть заполнены", "ОК");
        }
        OldPass.Text = string.Empty;
        NewPass.Text = string.Empty;
        reNewPass.Text = string.Empty;
    }
}