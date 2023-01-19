/*
BEGIN_TEST_DATA
  f: main
  ret: int
  args: int
  input: 12
  output: 9
  error: ""
  filename: "dsp/slice_5"
END_TEST_DATA
*/

span<float, 8> data = { 1.0f, 2.0f, 3.0f, 4.0f, 5.0f, 6.0f, 7.0f, 8.0f };

int main(int input)
{
	auto d = slice(data, 8, 0);
	auto d2 = slice(d, 8, 0);
	
	int numElements = 0;
	
	for(auto& s: d2)
    {
        s = 9.0f;
    }
	    
	return (int)data[5];
}

