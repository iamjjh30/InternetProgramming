fetch('header.html')
    .then(response => response.text())
    .then(data => {
        const headerElement = document.createElement('div');
        headerElement.innerHTML = data;
        document.getElementById('header-placeholder').appendChild(headerElement);

        // ✅ 드롭다운 이벤트 연결 (header가 DOM에 삽입된 후에 해야 함)
        const button = headerElement.querySelector('#categoryBtn');
        const dropdown = headerElement.querySelector('#dropdownMenu');

        if (button && dropdown) {
            button.addEventListener('click', function (e) {
                dropdown.classList.toggle('active');
                e.stopPropagation();
            });

            document.addEventListener('click', function (e) {
                if (!dropdown.contains(e.target) && e.target !== button) {
                    dropdown.classList.remove('active');
                }
            });
        }
    });
