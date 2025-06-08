namespace PickUpPoint;

using Microsoft.Maui.Controls;
using System.Data;

public partial class WarehouseOccupancyPage : ContentPage
{
    private DatabaseConnection _databaseConnection = new DatabaseConnection();
    public WarehouseOccupancyPage()
    {
        InitializeComponent();
        DBConnect();
    }

    private void DBConnect()
    {
        string query = "select * from warehouse order by id;";
        DataTable dataTable = _databaseConnection.ExecuteQuery(query);
        CreateOrderGrid(dataTable);
    }

    private void CreateOrderGrid(DataTable dataTable)
    {
        SquaresGrid.Children.Clear();
        SquaresGrid.ColumnDefinitions.Clear();
        SquaresGrid.RowDefinitions.Clear();

        var groupedData = dataTable.AsEnumerable()
            .GroupBy(r => r.Field<int>("size_id"))
            .OrderByDescending(g => g.Key)
            .ToList();

        int totalRows = 0;

        foreach (var group in groupedData)
        {
            int size = group.Key;
            var cells = group.ToList();
            int rowsInGroup = (int)Math.Ceiling(cells.Count / 10.0);

            SquaresGrid.RowDefinitions.Add(new RowDefinition { Height = GridLength.Auto });
            SquaresGrid.RowDefinitions.Add(new RowDefinition { Height = GridLength.Auto });

            var header = new Label
            {
                Text = GetSizeLabel(size),
                HorizontalOptions = LayoutOptions.Start,
                TextColor = Colors.White
            };
            Grid.SetRow(header, totalRows);
            Grid.SetColumnSpan(header, 10);
            SquaresGrid.Children.Add(header);

            totalRows++;
            for (int i = 0; i < cells.Count; i++)
            {
                int row = totalRows + i / 10;
                int col = i % 10;

                while (row >= SquaresGrid.RowDefinitions.Count)
                {
                    SquaresGrid.RowDefinitions.Add(new RowDefinition { Height = 50 });
                }

                DataRow cellData = cells[i];
                var square = CreateCell(cellData);
                Grid.SetRow(square, row);
                Grid.SetColumn(square, col);
                SquaresGrid.Children.Add(square);
            }

            totalRows += rowsInGroup;
        }

        for (int i = 0; i < 10; i++)
        {
            SquaresGrid.ColumnDefinitions.Add(new ColumnDefinition { Width = 50 });
        }
    }

    private Frame CreateCell(DataRow cellData)
    {
        int id = cellData.Field<int>("id");
        int status = cellData.Field<int>("status_id");
        int size = cellData.Field<int>("size_id");

        return new Frame
        {
            WidthRequest = GetSizeValue(size),
            HeightRequest = GetSizeValue(size),
            CornerRadius = 8,
            BackgroundColor = (status == 1) ? Colors.LightGreen : Colors.LightCoral,
            Content = new Label
            {
                Text = id.ToString(),
                VerticalOptions = LayoutOptions.Center,
                HorizontalOptions = LayoutOptions.Center
            },
            Padding = 0
        };
    }

    private string GetSizeLabel(int size) => size switch
    {
        3 => "Большие ячейки",
        2 => "Средние ячейки",
        1 => "Маленькие ячейки",
        _ => "Неизвестный размер"
    };

    private double GetSizeValue(int size) => size switch
    {
        3 => 45,
        2 => 35,
        1 => 25,
        _ => 25
    };
}