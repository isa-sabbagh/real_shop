import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Providers/product.dart';
import '../Providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = './edit-product';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descFocusNode = FocusNode();
  final _imgUrlFocusNode = FocusNode();
  final _imgUrlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var _editProduct =
      Product(id: null, title: '', desc: '', price: 0, imgUrl: '');
  var _initialValues = {
    'title': '',
    'desc': '',
    'price': '',
    'imgUrl': '',
  };

  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
    _imgUrlFocusNode.addListener(_updateImgUrl);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        _editProduct =
            Provider.of<Products>(context, listen: false).finddById(productId);
        _initialValues = {
          'title': _editProduct.title,
          'desc': _editProduct.desc,
          'price': _editProduct.price.toString(),
          'imgUrl': '',
        };
        _imgUrlController.text = _editProduct.imgUrl;
      }
      _isInit = false;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _imgUrlFocusNode.removeListener(_updateImgUrl);
    _priceFocusNode.dispose();
    _imgUrlFocusNode.dispose();
    _descFocusNode.dispose();
    _imgUrlController.dispose();
  }

  void _updateImgUrl() {
    if (!_imgUrlFocusNode.hasFocus) {
      if ((!_imgUrlController.text.startsWith('http') &&
              !_imgUrlController.text.startsWith('https')) ||
          (_imgUrlController.text.endsWith('.png') &&
              _imgUrlController.text.endsWith('.jpg') &&
              _imgUrlController.text.endsWith('.jpeg'))) return;

      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    final isFinal = _formKey.currentState.validate();
    if (!isFinal) return;

    _formKey.currentState.save();
    setState(() => _isLoading = true);

    if (_editProduct.id != null) {
      await Provider.of<Products>(context, listen: false)
          .updateProduct(_editProduct.id, _editProduct);
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editProduct);
      } catch (e) {
        await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                    title: Text('An error Occurred!'),
                    content: Text('Some Thing wrong !!!'),
                    actions: [
                      FlatButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: Text('Ok!'))
                    ]));
      }
    }
    setState(() => _isLoading = false);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Edit Product'), actions: [
          IconButton(onPressed: _saveForm, icon: Icon(Icons.save))
        ]),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Padding(
                padding: EdgeInsets.all(16),
                child: Form(
                    key: _formKey,
                    child: ListView(children: [
                      TextFormField(
                        initialValue: _initialValues['title'],
                        decoration: InputDecoration(labelText: 'Title'),
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) => FocusScope.of(context)
                            .requestFocus(_priceFocusNode),
                        validator: (val) {
                          if (val.isEmpty) 'please enter value';
                          return null;
                        },
                        onSaved: (val) => _editProduct = Product(
                            id: _editProduct.id,
                            title: val,
                            desc: _editProduct.desc,
                            price: _editProduct.price,
                            imgUrl: _editProduct.imgUrl,
                            isFav: _editProduct.isFav),
                      ),
                      TextFormField(
                        initialValue: _initialValues['price'],
                        decoration: InputDecoration(labelText: 'Price'),
                        textInputAction: TextInputAction.next,
                        focusNode: _priceFocusNode,
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_descFocusNode),
                        validator: (val) {
                          if (val.isEmpty) 'please enter price';

                          if (double.tryParse(val) == null)
                            'please enter price';

                          if (double.tryParse(val) <= 0)
                            'please enter more than 0';

                          return null;
                        },
                        onSaved: (val) => _editProduct = Product(
                            id: _editProduct.id,
                            title: _editProduct.title,
                            desc: _editProduct.desc,
                            price: double.parse(val),
                            imgUrl: _editProduct.imgUrl,
                            isFav: _editProduct.isFav),
                      ),
                      TextFormField(
                        initialValue: _initialValues['desc'],
                        decoration: InputDecoration(labelText: 'Descraption'),
                        maxLines: 3,
                        keyboardType: TextInputType.multiline,
                        focusNode: _descFocusNode,
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_descFocusNode),
                        validator: (val) {
                          if (val.isEmpty) 'please enter price';

                          if (double.tryParse(val) <= 10)
                            'please enter more than 0';

                          return null;
                        },
                        onSaved: (val) => _editProduct = Product(
                            id: _editProduct.id,
                            title: _editProduct.title,
                            desc: val,
                            price: _editProduct.price,
                            imgUrl: _editProduct.imgUrl,
                            isFav: _editProduct.isFav),
                      ),
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              margin: EdgeInsets.only(top: 8, right: 10),
                              decoration: BoxDecoration(
                                  border:
                                      Border.all(width: 1, color: Colors.grey)),
                              child: _imgUrlController.text.isEmpty
                                  ? Text('Enter a URL')
                                  : FittedBox(
                                      child: Image.network(
                                          _imgUrlController.text,
                                          fit: BoxFit.cover)),
                            ),
                            Expanded(
                                child: TextFormField(
                              controller: _imgUrlController,
                              decoration:
                                  InputDecoration(labelText: 'Image Url'),
                              keyboardType: TextInputType.url,
                              focusNode: _imgUrlFocusNode,
                              onFieldSubmitted: (_) => FocusScope.of(context)
                                  .requestFocus(_descFocusNode),
                              validator: (val) {
                                if (val.isEmpty) 'please enter url';
                                if (!val.startsWith('http') &&
                                    !val.startsWith('https'))
                                  'please enter valid Url';
                                if (!val.endsWith('.png') &&
                                    !val.endsWith('jpg'))
                                  'please enter valid Url';
                                return null;
                              },
                              onSaved: (val) => _editProduct = Product(
                                  id: _editProduct.id,
                                  title: _editProduct.title,
                                  desc: _editProduct.desc,
                                  price: _editProduct.price,
                                  imgUrl: val,
                                  isFav: _editProduct.isFav),
                            ))
                          ])
                    ]))));
  }
}
