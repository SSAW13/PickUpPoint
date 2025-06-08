using System.Data;

namespace PickUpPoint;

public partial class OrderProcessingPage : ContentPage
{
    DatabaseConnection _databaseConnection = new DatabaseConnection();
	public OrderProcessingPage()
	{
		InitializeComponent();
	}
    DataTable dataTable;
    private async void SearchOrderClicked(object sender, EventArgs e)
    {
		if (!string.IsNullOrWhiteSpace(OrderIdEntry.Text))
		{
			string query = "select * from ordersOnWarehouse where id = " + OrderIdEntry.Text +";";
            dataTable = _databaseConnection.ExecuteQuery(query);

            InfoLabel.Text = "Заказ: ";
            PhoneLabel.Text = "Номер клиента: ";
            CellLabel.Text = "Ячейка: ";

            try
            {
                Order.IsVisible = true;
                InfoLabel.Text += "№" + dataTable.Rows[0][0] + " до " + dataTable.Rows[0][5];
                PhoneLabel.Text += dataTable.Rows[0][4];
                CellLabel.Text += dataTable.Rows[0][1];

            }
            catch (Exception)
            {
                Order.IsVisible= false;
                await DisplayAlert("Ошибка", "Заказ не найден", "OK");

            }
        }
    }

    private async void IssueOrder(object sender, EventArgs e)
    {
        string query = "select IssueOrder(" + dataTable.Rows[0][0] + ", " + dataTable.Rows[0][1] + ")";
        DataTable dataTable1 = _databaseConnection.ExecuteQuery(query);
        await DisplayAlert("Успешно", "Заказ выдан", "ОК");
        Order.IsVisible = false;
    }

    private void OnEntryTextChanged(object sender, TextChangedEventArgs e)
	{
        Entry entry = (Entry)sender;
        string newText = e.NewTextValue;

        if (string.IsNullOrWhiteSpace(newText)) return;

        string filteredText = new string(newText.Where(char.IsDigit).ToArray());

        if (newText != filteredText)
        {
            entry.Text = filteredText;
        }
    }
}