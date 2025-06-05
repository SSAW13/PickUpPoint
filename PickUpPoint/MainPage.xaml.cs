namespace PickUpPoint
{
    public partial class MainPage : ContentPage
    {
        int count = 0;

        public MainPage()
        {
            InitializeComponent();
            IsAdmin();
        }

        private async void IsAdmin()
        {
            string res = await SecureStorage.Default.GetAsync("role");
            if (res == "Admin")
            {
                admin.IsVisible = true;
            }
        }

        private async void OrderProcessingClicked(object sender, EventArgs e)
        {
            await Navigation.PushAsync(new OrderProcessingPage());
        }
        private async void WriteOffClicked(object sender, EventArgs e)
        {
            await Navigation.PushAsync(new WriteOffPage());
        }
        private async void AddOrderClicked(object sender, EventArgs e)
        {
            await Navigation.PushAsync(new AddOrderPage());
        }
        private async void AdminPanelClicked(object sender, EventArgs e)
        {
            await Navigation.PushAsync(new AdminPanelPage());
        }

        private async void PersonalCabinetClicked(object sender, EventArgs e)
        {
            await Navigation.PushAsync(new PersonalCabinetPage());
        }

        private async void WarehouseOccupancyClicked(object sender, EventArgs e)
        {
            await Navigation.PushAsync(new WarehouseOccupancyPage());
        }
    }

}
