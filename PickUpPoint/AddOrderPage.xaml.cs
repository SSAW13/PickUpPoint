namespace PickUpPoint;

public partial class AddOrderPage : ContentPage
{
	public AddOrderPage()
	{
		InitializeComponent();
	}

    private async void AddNewOrder(object sender, EventArgs e)
    {
        if(!string.IsNullOrWhiteSpace(Phone.Text) && !string.IsNullOrWhiteSpace(Num.Text))
        {
            await DisplayAlert("Succeses", "qwe", "OK");
        } else
        {
            await DisplayAlert("Error", "qwe", "OK");

        }
    }
}