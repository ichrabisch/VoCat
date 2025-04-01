using VoCat.Business.Repository;
using VoCat.Business.Storage;
using VoCat.Orchestration;
using VoCat.SharedKernel;
using VoCat.SharedKernel.Data.PostgreSQL;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddControllers();

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddScoped<PostgresConnectionSettings>();
builder.Services.AddScoped<PostgresConnectionManager>();
builder.Services.AddScoped<UserRepository>();
builder.Services.AddScoped<UserOrchestration>();
builder.Services.AddScoped<FolderRepository>();
builder.Services.AddScoped<FolderOrchestration>();
builder.Services.AddScoped<WordRepository>();
builder.Services.AddScoped<WordOrchestration>();
builder.Services.AddScoped<S3Service>(provider =>
{
    var configuration = provider.GetRequiredService<IConfiguration>();
    var accessKey = configuration["AWS:AccessKey"];
    var secretKey = configuration["AWS:SecretKey"];
    var bucketName = configuration["AWS:BucketName"];
    var region = configuration["AWS:Region"] ?? "eu-central-1"; 

    if (string.IsNullOrEmpty(accessKey) || string.IsNullOrEmpty(secretKey) || string.IsNullOrEmpty(bucketName) || string.IsNullOrEmpty(region))
    {
        throw new Exception(GlobalConsts.AWSConfigurationError);
    }

    return new S3Service(accessKey, secretKey, bucketName, region);
});
var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseAuthorization();

app.MapControllers();

app.Run();
