using System.Data;

namespace PickUpPoint;

public partial class AddOrderPage : ContentPage
{
    DatabaseConnection _databaseConnection = new DatabaseConnection();
	public AddOrderPage()
	{
		InitializeComponent();
	}
    private void DbWarehouse(string size)
    {
        int sizeDB = 3;
        switch (size)
        {
            case "s":
                sizeDB = 1; break;
            case "m":
                sizeDB = 2; break;
            case "l":
                sizeDB = 3; break;
            default:
                break;
        }
        CellEditor.IsVisible = true;
        string query = "select * from warehouse where size_id = " + sizeDB.ToString() + " order by id ;";
        DataTable dataTable = _databaseConnection.ExecuteQuery(query);
        CellEditor.Items.Clear();
        foreach (DataRow row in dataTable.Rows)
        {
            if (row[2]?.ToString() == "1")
            {
                CellEditor.Items.Add(row[0]?.ToString() ?? "N/A");
            }
        }
    }

    private async void AddNewOrder(object sender, EventArgs e)
    {
        if(!string.IsNullOrWhiteSpace(Phone.Text) && CellEditor.SelectedIndex != -1)
        {
            int sizeDB = 3;
            switch (SizeEditor.SelectedItem.ToString())
            {
                case "s":
                    sizeDB = 1; break;
                case "m":
                    sizeDB = 2; break;
                case "l":
                    sizeDB = 3; break;
                default:
                    break;
            }
            string query = "select AddOrder(" + CellEditor.SelectedItem.ToString() + ", " + sizeDB + ", \'" + Phone.Text +"\');";
            _databaseConnection.ExecuteQuery(query);
            await DisplayAlert("Успех", "Заказ успешно добавлен на склад", "OK");
        } else
        {
            await DisplayAlert("Ошибка", "Заполнены не все поля", "OK");

        }
    }

    private void SizeEditor_SelectedIndexChanged(object sender, EventArgs e)
    {
        string size = SizeEditor.SelectedItem.ToString();
        DbWarehouse(size);
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