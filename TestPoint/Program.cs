using System.Net.Sockets;
using VoCat.Business.Mappers;
using VoCat.Business.Repository;
using VoCat.Business.Storage;
using VoCat.Orchestration;
using VoCat.SharedKernel.Data.PostgreSQL;
using VoCat.Types;
using VoCat.Types.Requests;

#region connection
PostgresConnectionSettings connectionSettings = new PostgresConnectionSettings();   
PostgresConnectionManager connectionManager = new PostgresConnectionManager(connectionSettings);
#endregion

#region User
UserRepository userRepository = new UserRepository(connectionManager);
UserOrchestration userOrchestration = new UserOrchestration(userRepository);
User userContract = new User();

userContract.Email = "whitebirdsdk@gmail.com";
userContract.PasswordHash = "123.";
UserRequest userRequest = new UserRequest(userContract);

var user= userOrchestration.Login(userRequest);
#endregion

#region Folder

FolderRepository folderRepository = new FolderRepository(connectionManager);

Folder contract = new Folder();
contract.UserId = user.Data.UserId;

FolderRequest folderRequest = new FolderRequest(contract);
folderRequest.FolderContract.FolderId = Guid.Parse("18bfc605-91f2-4b58-9599-f4bf8ce94f9c");
folderRequest.FolderContract.Name = "pati";
folderRequest.FolderContract.ParentFolderId = Guid.Parse("60576dcf-650c-4507-a635-f7a1aad309f0");
folderRepository.UpdateFolder(folderRequest);

var folders = folderRepository.SelectAllFolders(folderRequest);

Console.WriteLine(folders);
#endregion

#region Word
Word contr = new Word();
contr.WordId = Guid.NewGuid();
contr.WordText = "cat";
contr.Translation = "kedy";
contr.FolderId = folders.Data[0].FolderId;
contr.UserId = user.Data.UserId;

WordRequest request = new WordRequest(contr);
WordRepository wordRepository = new WordRepository(connectionManager);
//wordRepository.CreateWord(request);
request.WordContract.FolderId = folders.Data[1].FolderId;
var words = wordRepository.SelectWordsByFolderId(request);
Console.WriteLine(words.Data[0].WordText);

request.WordContract.WordId = words.Data[0].WordId;
var word = wordRepository.SelectWordById(request);
Console.WriteLine("kelime: " + word.Data.WordText);

request.WordContract.WordId = words.Data[0].WordId;
request.WordContract.Translation = "KEDY";
request.WordContract.MasteryLevel = 2;
wordRepository.UpdateWord(request);
#endregion
#region s3
var s3Client = new S3Service(
    accessKey: "AKIA47GCAKA5WKVGEN7J",
    secretKey: "f608zdDu9ThR3YPwgdltA/hjW3eUUJHAuGQcHcLq",
    bucketName: "vocatbucket"
);
string filePath = @"C:\Users\die_l\Desktop\VoCat.SQL\Cat03.jpg"; // Replace with your file path

// Read file bytes
byte[] fileBytes = File.ReadAllBytes(filePath);

// Get file name from path
string fileName = Path.GetFileName(filePath);

// Get content type based on file extension
string contentType = "image/jpeg";

// Generate unique identifier
Guid wordId = Guid.Parse("89dbb6d7-9c06-4308-a3c1-800def982e07");
Guid userId = Guid.Parse("8966fce6-1b42-43af-b4f1-3706758c18c8");

// Upload to S3
string fileKey = (await s3Client.UploadWordImageAsync(wordId, userId, fileBytes, contentType)).Data;
Console.WriteLine($"File uploaded successfully. File key: {fileKey}");
#endregion 