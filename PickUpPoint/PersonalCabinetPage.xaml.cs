namespace PickUpPoint;
using Microsoft.Maui.Controls;

public partial class PersonalCabinetPage : ContentPage
{
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

        lastname.Text = l1;
        name.Text = l2;
        role.Text = l3;
    }

    private async void LogoutClicked(object sender, EventArgs e)
    {
        await Shell.Current.GoToAsync("//LoginPage", true);

        await Shell.Current.Navigation.PopToRootAsync();

        SecureStorage.Default.RemoveAll();
    }

    private async void ChangeClicked(object sender, EventArgs e)
    {
        await DisplayAlert("Ошибка", "Введены некорректные данные для смены пароля", "OK");
    }
}